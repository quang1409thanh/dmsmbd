
### 1. Nearest Neighbor Vector Search

```sql
SELECT
 g1.name AS galaxy_1,
 g2.name AS galaxy_2,
 VECTOR_DISTANCE(g2.embedding, g1.embedding) AS distance
FROM galaxies g1, galaxies g2
WHERE g1.id = 1
ORDER BY distance ASC;
```

**Giải thích:**
- **Mục đích:** Truy vấn này nhằm tìm các đối tượng (ở đây là các thiên hà) có vector gần nhất với một thiên hà cụ thể.
- **Chi tiết:**
  - `g1` và `g2` là hai alias (bí danh) của bảng `galaxies`.
  - `VECTOR_DISTANCE(g2.embedding, g1.embedding)` tính toán khoảng cách giữa vector `embedding` của hai thiên hà.
  - `g1.id = 1` xác định thiên hà cụ thể (với `id = 1`) để tìm các thiên hà gần nhất với nó.
  - Kết quả được sắp xếp theo khoảng cách tăng dần (`distance ASC`).

### 2. Specify Distance Calculation Method

#### Cosine Distance:

```sql
SELECT
 g1.name AS galaxy_1,
 g2.name AS galaxy_2,
 VECTOR_DISTANCE(g2.embedding, g1.embedding, COSINE) AS distance
FROM galaxies g1, galaxies g2
WHERE g1.id = 1
ORDER BY distance ASC;
```

**Giải thích:**
- **Mục đích:** Tương tự như truy vấn trên, nhưng sử dụng Cosine distance để tính toán khoảng cách giữa các vector.
- **Chi tiết:** Tham số `COSINE` được thêm vào hàm `VECTOR_DISTANCE` để chỉ định phương pháp tính khoảng cách.

#### Dot Product Distance:

```sql
SELECT
 g1.name AS galaxy_1,
 g2.name AS galaxy_2,
 VECTOR_DISTANCE(g2.embedding, g1.embedding, DOT) AS distance
FROM galaxies g1, galaxies g2
WHERE g1.id = 1
ORDER BY distance ASC;
```

**Giải thích:**
- **Mục đích:** Tương tự như trên, nhưng sử dụng Dot Product distance.
- **Chi tiết:** Tham số `DOT` chỉ định phương pháp tính khoảng cách.

#### Euclidean Distance:

```sql
SELECT
 g1.name AS galaxy_1,
 g2.name AS galaxy_2,
 VECTOR_DISTANCE(g2.embedding, g1.embedding, EUCLIDEAN) AS distance
FROM galaxies g1, galaxies g2
WHERE g1.id = 1
ORDER BY distance ASC;
```

**Giải thích:**
- **Mục đích:** Sử dụng Euclidean distance để tính khoảng cách giữa các vector.
- **Chi tiết:** Tham số `EUCLIDEAN` chỉ định phương pháp tính khoảng cách.

### 3. Mysterious Vector Distance Notation

```sql
SELECT
 g1.name AS galaxy_1,
 g2.name AS galaxy_2,
 g2.embedding <=> g1.embedding AS distance
FROM galaxies g1, galaxies g2
WHERE g1.id = 1
ORDER BY distance ASC;
```

**Giải thích:**
- **Mục đích:** Truy vấn này có cùng mục đích như các truy vấn trên, nhưng sử dụng cú pháp đặc biệt để tính khoảng cách giữa các vector.
- **Chi tiết:** Toán tử `<=>` được sử dụng để tính khoảng cách giữa hai vector. Đây là một cách viết tắt và có thể tương đương với một trong các phương pháp tính toán khoảng cách nêu trên (cosine, dot product, hoặc euclidean) tùy theo thiết lập mặc định của hệ thống hoặc cấu hình cụ thể.

### Tổng kết

Các truy vấn bạn đề cập đến là một phần của tính năng tìm kiếm vector mới trong Oracle Database 23c. Chúng cho phép thực hiện các phép tính khoảng cách giữa các vector nhúng (embedding vectors) của các đối tượng trong cơ sở dữ liệu, hỗ trợ các ứng dụng như tìm kiếm gần nhất, phân cụm, và các thuật toán học máy khác.

Nếu bạn cần thêm thông tin chi tiết hoặc ví dụ cụ thể về cách triển khai các truy vấn này, hãy cho mình biết nhé!

