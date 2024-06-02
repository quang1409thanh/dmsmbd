Dưới đây là giải thích chi tiết các bước thiết lập Data Guard

### Thiết lập biến môi trường

```powershell
ORACLE_HOME=C:\Oracle\V19Database
ORACLE_BASE=C:\Oracle\V19DatabaseBase
ORACLE_SID=ORA

[Environment]::SetEnvironmentVariable("ORACLE_BASE", "C:\Oracle\V19DatabaseBase", "Machine")
[Environment]::SetEnvironmentVariable("ORACLE_HOME", "C:\Oracle\V19Database", "Machine")
[Environment]::SetEnvironmentVariable("ORACLE_SID", "ORA", "Machine")
```
- **Giải thích:** Thiết lập các biến môi trường cần thiết cho Oracle Database.

### Tạo LISTENER trên cả hai máy với cổng 1522

```powershell
netca
```
- **Giải thích:** Sử dụng Net Configuration Assistant (netca) để tạo listener cho Oracle Database trên cả hai máy.

### Tạo thư mục cho Oracle Database trên cả hai nút

```powershell
mkdir D:\ORADATA\
mkdir D:\ORADATA\ORA\
mkdir D:\ORADATA\ORA\FRA
```
- **Giải thích:** Tạo các thư mục cần thiết để lưu trữ dữ liệu của Oracle Database.

### Cấu hình Primary Database trên NODE1 (WIN19PRIMARY)

```sql
. oraenv
ora
sqlplus / as sysdba

STARTUP MOUNT;

SELECT NAME, DB_UNIQUE_NAME, OPEN_MODE, LOG_MODE, FLASHBACK_ON, FORCE_LOGGING FROM V$DATABASE;

SHOW PARAMETER NAME;
ALTER SYSTEM SET DB_UNIQUE_NAME='ORAP'                       SCOPE=SPFILE; 
ALTER SYSTEM SET REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE         SCOPE=SPFILE;
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 10G            SCOPE=BOTH;
ALTER SYSTEM SET DB_RECOVERY_FILE_DEST='D:\ORADATA\ORA\FRA'  SCOPE=BOTH;

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
SHOW PARAMETER NAME;

ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ARCHIVE LOG LIST;

ALTER SYSTEM SET DB_FLASHBACK_RETENTION_TARGET = 60    SCOPE=BOTH;
ALTER DATABASE FLASHBACK ON;
ALTER DATABASE FORCE LOGGING;

ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORAP' SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=ORAS LGWR ASYNC VALID_FOR=(ALL_LOGFILES,PRIMARY_ROLE)         DB_UNIQUE_NAME=ORAS' SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_1=ENABLE            SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE            SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(ORAS,ORAP)' SCOPE=BOTH;
ALTER SYSTEM SET FAL_CLIENT='ORAP'                          SCOPE=BOTH;
ALTER SYSTEM SET FAL_SERVER='ORAS'                          SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_MAX_PROCESSES=30               SCOPE=BOTH;
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO               SCOPE=BOTH;
ALTER SYSTEM SET LOCAL_LISTENER='WIN19PRIMARY:1522'         SCOPE=BOTH;
ALTER SYSTEM REGISTER;

ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 4 ('D:\ORADATA\ORA\REDO04.LOG') SIZE 200M; 
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 5 ('D:\ORADATA\ORA\REDO05.LOG') SIZE 200M; 
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 6 ('D:\ORADATA\ORA\REDO06.LOG') SIZE 200M; 
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 7 ('D:\ORADATA\ORA\REDO07.LOG') SIZE 200M; 

SELECT thread#, group#, sequence#, status, bytes FROM v$standby_log;

SELECT MEMBER FROM V$LOGFILE ORDER BY GROUP#;

ALTER SYSTEM SWITCH LOGFILE;

ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE PERFORMANCE;

CREATE PFILE FROM SPFILE;
```
- **Giải thích:**
  - Khởi động cơ sở dữ liệu ở chế độ MOUNT.
  - Đặt các thông số cần thiết cho Data Guard.
  - Thiết lập chế độ Archive Log và bật tính năng Flashback.
  - Cấu hình các đích lưu trữ nhật ký (LOG_ARCHIVE_DEST) để đồng bộ hóa với Standby Database.
  - Tạo các tệp nhật ký standby.

### Cấu hình Standby Database trên NODE2 (WIN19STANDBY)

```sql
. oraenv
ora
sqlplus / as sysdba

cd $ORACLE_HOME/dbs

Copy INITORA.ORA  to WIN19STANDBY:%ORACLE_HOME%/database
Copy PWDORA.ora   to WIN19STANDBY:%ORACLE_HOME%/database

gedit $ORACLE_HOME/dbs/initora.ora 
   1. Replace ORAP with ORAS for db_unique_name
   2. Change the LOCAL_LISTENER to WIN19STANDBY:1522
```
- **Giải thích:**
  - Sao chép và chỉnh sửa tệp cấu hình từ Primary sang Standby.
  - Thay đổi tên duy nhất của cơ sở dữ liệu và địa chỉ listener cho Standby.

### Khôi phục Standby Database từ Primary

```powershell
mkdir D:\ORADATA\
mkdir D:\ORADATA\ORA\
mkdir D:\ORADATA\ORA\FRA

oradim -NEW -SID ORA -STARTMODE manual -PFILE "C:\Oracle\V19Database\database\INITORA.ORA"

. oraenv
ora

SHUT ABORT;
STARTUP NOMOUNT;
SHOW PARAMETER NAME;
```
- **Giải thích:**
  - Tạo các thư mục cần thiết trên Standby.
  - Tạo dịch vụ Oracle mới trên Standby với chế độ khởi động thủ công.

### Sao chép và khôi phục cơ sở dữ liệu trên Standby

```sql
rman TARGET sys/password@ORAP AUXILIARY sys/password@ORAS

DUPLICATE TARGET DATABASE
  FOR STANDBY
  FROM ACTIVE DATABASE
  DORECOVER
  SPFILE
    SET db_unique_name='ORAS' COMMENT 'IS STANDBY'
  NOFILENAMECHECK;
```
- **Giải thích:**
  - Sử dụng RMAN để sao chép cơ sở dữ liệu từ Primary sang Standby.

### Cấu hình Standby Database

```sql
SHOW PARAMETER NAME;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=ORAS' SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=ORAP LGWR ASYNC VALID_FOR=(ALL_LOGFILES,PRIMARY_ROLE)         DB_UNIQUE_NAME=ORAP' SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_1=ENABLE            SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE            SCOPE=BOTH;
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(ORAS,ORAP)' SCOPE=BOTH;
ALTER SYSTEM SET FAL_CLIENT='ORAS'                          SCOPE=BOTH;
ALTER SYSTEM SET FAL_SERVER='ORAP'                          SCOPE=BOTH;
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO               SCOPE=BOTH;
ALTER SYSTEM SET LOCAL_LISTENER='WIN19STANDBY:1522'         SCOPE=BOTH;
ALTER SYSTEM REGISTER;

SELECT thread#, group#, sequence#, status, bytes FROM v$standby_log;

SELECT MEMBER FROM V$LOGFILE ORDER BY GROUP#;

ALTER SYSTEM SWITCH LOGFILE;

SHUTDOWN IMMEDIATE;
STARTUP;
ARCHIVE LOG LIST;
```
- **Giải thích:**
  - Cấu hình các tham số Data Guard cho Standby Database.
  - Thực hiện các kiểm tra cần thiết để đảm bảo cấu hình chính xác.

### Thiết lập tệp cấu hình mạng cho cả hai nút (listener.ora và tnsnames.ora)

**WIN19PRIMARY**

- **listener.ora**

```plaintext
SID_LIST_LISTENER =
  (SID_LIST =
   (SID_DESC =
      (ORACLE_HOME = C:\Oracle\V19Database)
      (SID_NAME = ORA)
    )
  )
  
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = WIN19PRIMARY)(PORT = 1522))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1522))
    )
  )
```

- **tnsnames.ora**

```plaintext
ORAP =
  (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = WIN19PRIMARY)(PORT = 1522))
    (CONNECT_DATA = (SERVER = DEDICATED)  (SERVICE_NAME = ORAP)))

ORAS =
  (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = WIN19STANDBY)(PORT = 1522))
    (CONNECT_DATA = (SERVER = DEDICATED)  (SERVICE_NAME = ORAS)))
```

**WIN19STANDBY**

- **listener.ora**

```plaintext
SID_LIST_LISTENER =
  (SID_LIST =
  

 (SID_DESC =
      (ORACLE_HOME = C:\Oracle\V19Database)
      (SID_NAME = ORA)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = WIN19STANDBY)(PORT = 1522))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1522))
    )
  )
```

- **tnsnames.ora**

```plaintext
ORAP =
  (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = WIN19PRIMARY)(PORT = 1522))
    (CONNECT_DATA = (SERVER = DEDICATED)  (SERVICE_NAME = ORAP)))

ORAS =
  (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = WIN19STANDBY)(PORT = 1522))
    (CONNECT_DATA = (SERVER = DEDICATED)  (SERVICE_NAME = ORAS)))
```

- **Giải thích:**
  - Cấu hình các tệp listener và tnsnames để đảm bảo kết nối mạng giữa Primary và Standby.

Như vậy, các bước trên bao gồm toàn bộ quy trình thiết lập Oracle Data Guard, từ cấu hình ban đầu, sao chép cơ sở dữ liệu, đến cấu hình Data Guard cho cả hai nút.

ref: [hướng dẫn](https://www.dropbox.com/scl/fi/n06m0fwb4kudk9zuy7nvo/Oracle-19c-Data-Guard-on-Windows-Setup.sql?rlkey=eo210dw8w798gc998pe3gizga&e=1&dl=0)

Sau khi thiết lập Oracle Data Guard, bạn sẽ có các chức năng cơ bản sau:

1. **Đồng bộ hóa dữ liệu giữa Primary và Standby:**
   - Dữ liệu được cập nhật ở Primary Database sẽ tự động được đồng bộ hóa với Standby Database. Điều này đảm bảo rằng Standby Database luôn có bản sao mới nhất của dữ liệu từ Primary Database.

2. **Chuyển đổi vai trò giữa Primary và Standby:**
   - Bạn có thể chuyển đổi vai trò giữa Primary Database và Standby Database. Điều này cho phép Standby trở thành Primary và ngược lại, mà không mất dữ liệu. Việc chuyển đổi này giúp đảm bảo tính sẵn sàng cao của hệ thống và có thể được thực hiện cho mục đích bảo trì hoặc trong trường hợp khẩn cấp khi Primary gặp sự cố.
   Ngoài hai chức năng cơ bản đã đề cập ở trên, Oracle Data Guard còn cung cấp một số chức năng khác nhằm đảm bảo tính sẵn sàng và bảo vệ dữ liệu của hệ thống. Dưới đây là một số chức năng quan trọng khác:

3. **Bảo vệ dữ liệu:**
   - Oracle Data Guard cung cấp các chế độ bảo vệ dữ liệu khác nhau như Maximum Protection, Maximum Availability, và Maximum Performance, giúp bạn lựa chọn mức độ bảo vệ phù hợp với nhu cầu của hệ thống.

4. **Kiểm soát và quản lý trạng thái:**
   - Bạn có thể kiểm soát và quản lý trạng thái của các database trong hệ thống Data Guard, bao gồm trạng thái chuyển đổi (switchover), trạng thái sao lưu (backup), và trạng thái phục hồi (recovery).

5. **Failover tự động:**
   - Chức năng Fast-Start Failover cho phép tự động chuyển đổi Standby Database thành Primary Database trong trường hợp xảy ra sự cố với Primary Database mà không cần can thiệp của người quản trị.

6. **Thử nghiệm và kiểm tra hệ thống:**
   - Bạn có thể sử dụng Standby Database như một bản sao thử nghiệm của Primary Database mà không ảnh hưởng đến hoạt động của Primary, giúp bạn thử nghiệm các cập nhật hoặc thay đổi trước khi triển khai trên môi trường sản xuất.

7. **Truy vấn Standby Database:**
   - Oracle Data Guard cho phép truy vấn dữ liệu trực tiếp từ Standby Database mà không cần chuyển đổi thành Primary Database, giúp giảm tải cho Primary Database và cải thiện hiệu suất truy vấn.

Những chức năng này cùng nhau tạo nên một hệ thống Oracle Data Guard mạnh mẽ và linh hoạt, giúp bảo vệ và quản lý dữ liệu của bạn một cách hiệu quả và đáng tin cậy.


video: [youtube](https://youtu.be/Km4wyIV722k?si=hza_zyQoimd9EqQE)