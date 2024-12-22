---a
--1 
CREATE PROC xin_chao
AS BEGIN
print N'Xin chào'
END
--Execution_1
EXEC xin_chao
--2 
CREATE PROC CAU_2
@ten NVARCHAR(10)
AS BEGIN
print N'Xin chào';
print @ten
END
--Execution_2
EXEC CAU_2 N'Nguyễn Thế Anh'
--3
CREATE PROC CAU_3
@s1 int, @s2 int, @tg int out
AS BEGIN
SET @tg = @s1 + @s2;
PRINT N'Tổng là: ' + CAST(@tg AS NVARCHAR(20))
END
--EXECUTION_3
drop proc CAU_3
DECLARE @tg NVARCHAR(20)
EXEC CAU_3 1, 2, @tg
--4
CREATE PROC CAU_4
@s1 INT, @s2 INT, @max int, @tong INT out
AS BEGIN
SET @tong = @s1 + @s2;
if @s1 >= @s2 
set @max = @s1
else set @max = @s2
PRINT N'Số lớn nhất của ' + CAST(@s1 AS NVARCHAR(20)) + ' và ' + CAST(@s2 AS NVARCHAR(20)) + ' là ' + CAST(@max AS NVARCHAR(20))
END
--EXECUTION_4
drop proc CAU_4
declare @tong int
declare @max int
exec CAU_4 8, 7, 7, 8
--5 
CREATE PROC CAU_5
@s1 int, @s2 int, @max int out, @min int out
as begin
if @s1 >= @s2 
begin
	set @max = @s1
	set @min = @s2
end;
else
begin
	set @max = @s2
	set @min = @s1
end;
end
--execution
drop proc CAU_5
declare @max int
declare @min int
exec CAU_5 2, 3, @max out, @min out
select @max as MAX, @min as MIN
--6
CREATE PROC CAU_6
@n int, @count int
as begin
set @count = 1;
while (@count <= @n)
begin
	print @count;
	set @count = @count + 1;
end;
end
--execution
drop proc CAU_6
DECLARE @COUNT INT
exec CAU_6 10,@COUNT
--7
CREATE PROC CAU_7
@n int, @count int
as begin
set @count = 1;
while (@count <= @n)
begin
	if (@count % 2 = 0) 
	print @count;
	set @count = @count + 1;
end;
end
--execution
drop proc CAU_7
DECLARE @COUNT INT
exec CAU_7 10,@COUNT
--8
CREATE PROC CAU_8
@n int, @i int, @count int, @tong int
as begin
set @count = 1;
set @i = 0;
set @tong = 0;
while (@count <= @n)
begin
	if @count % 2 = 0
	begin
		set @tong = @tong + @count;
		set @i = @i + 1;
	end;
	set @count = @count + 1;
end;
print N'Tổng là: ' + CAST(@tong AS NVARCHAR(20))
print N'Số lượng là: ' + CAST(@i AS NVARCHAR(20));
end
--execution
drop proc CAU_8
DECLARE @count int
DECLARE @tong int
DECLARE @I INT
exec CAU_8 10, @i, @count, @tong



-- Trigger
-- 1
CREATE TRIGGER trg1 ON CAUTHU 
FOR INSERT 
AS
BEGIN
	DECLARE @vitri NVARCHAR(20)
	SELECT @vitri = VITRI FROM inserted

	IF @vitri IN (N'Thủ môn', N'Tiền đạo', N'Tiền vệ', N'Trung vệ', N'Hậu vệ')
		BEGIN
			PRINT N'Thêm cầu thủ mới thành công'
		END
	ELSE
		ROLLBACK TRANSACTION
END;
-- exec
SELECT * FROM CAUTHU;
INSERT INTO CAUTHU(HOTEN, VITRI, NGAYSINH, DIACHI, MACLB, MAQG, SO)
	   VALUES (N'Phạm Trung Hiếu', N'Trung vệ', '09-14-2001', NULL, 'SDN', 'VN', 5);
SELECT * FROM CAUTHU;

-- 2
CREATE TRIGGER trg2 ON CAUTHU
FOR INSERT
AS
BEGIN
	DECLARE @maclb VARCHAR(5), @so INT
	SELECT @maclb = MACLB, @so = SO FROM inserted

	IF (SELECT COUNT(*) FROM CAUTHU WHERE MACLB = @maclb AND SO = @so) > 1 -- đã tồn tại cầu thủ
		ROLLBACK TRANSACTION
	ELSE
		BEGIN
			PRINT N'Thêm cầu thủ mới thành công'
		END
END;
-- exec 
SELECT * FROM CAUTHU;
INSERT INTO CAUTHU(HOTEN, VITRI, NGAYSINH, DIACHI, MACLB, MAQG, SO)
	   VALUES (N'Ngô Đức Long', N'Hậu vệ', '05-25-2000', NULL, 'BBD', 'VN', 5);
SELECT * FROM CAUTHU;

-- 3. 
CREATE TRIGGER trg3 ON CAUTHU
FOR INSERT
AS
BEGIN
	PRINT N'Đã thêm cầu thủ mới'
END;
-- exec
SELECT * FROM CAUTHU;
INSERT INTO CAUTHU(HOTEN, VITRI, NGAYSINH, DIACHI, MACLB, MAQG, SO)
	   VALUES (N'Trần Linh Thắng', N'Tiền vệ', '07-18-1997', NULL, 'SDN', 'VN', 7);
SELECT * FROM CAUTHU;

-- 4. 
-- bộ chỉ được phép đăng ký tối đa 8 cầu thủ
CREATE TRIGGER trg4 ON CAUTHU
FOR INSERT
AS
BEGIN
	DECLARE @maclb VARCHAR(5), @maqg VARCHAR(5)
	SELECT @maclb = MACLB, @maqg = MAQG FROM inserted

	IF (SELECT COUNT(*) FROM CAUTHU WHERE MACLB = @maclb AND MAQG <> 'VN' GROUP BY MACLB) <= 8
		BEGIN
			PRINT N'Thêm cầu thủ mới thành công'
		END
	ELSE
		ROLLBACK TRANSACTION
END;
-- exec
SELECT * FROM CAUTHU;
INSERT INTO CAUTHU(HOTEN, VITRI, NGAYSINH, DIACHI, MACLB, MAQG, SO)
	   VALUES (N'Leonardo DiCaprio', N'Hậu vệ', '11-11-1974', NULL, 'GDT', 'TBN', 4);
SELECT * FROM CAUTHU;

-- 5
CREATE TRIGGER trg5 ON QUOCGIA
FOR INSERT
AS
BEGIN
	DECLARE @tenqg NVARCHAR(60)
	SELECT @tenqg = TENQG FROM inserted

	IF (SELECT COUNT(*) FROM QUOCGIA WHERE TENQG = @tenqg) > 1
		ROLLBACK TRANSACTION
	ELSE
		BEGIN
			PRINT N'Thêm quốc gia mới thành công'
		END
END;
-- exec
SELECT * FROM QUOCGIA;
INSERT INTO QUOCGIA(MAQG, TENQG)
	   VALUES ('CHN', N'Trung Quốc');
SELECT * FROM QUOCGIA;

-- 6
CREATE TRIGGER trg6 ON TINH
FOR INSERT
AS
BEGIN
	DECLARE @tentinh NVARCHAR(100)
	SELECT @tentinh = TENTINH FROM inserted

	IF (SELECT COUNT(*) FROM TINH WHERE TENTINH = @tentinh) > 1
		ROLLBACK TRANSACTION
	ELSE
		BEGIN
			PRINT N'Thêm tỉnh mới thành công'
		END
END;
-- exec
SELECT * FROM TINH;
INSERT INTO TINH(MATINH, TENTINH)
	   VALUES ('TB', N'Thái Bình');
SELECT * FROM TINH;

-- 7

-- 8. 
-- 8a. 
CREATE TRIGGER trg8a ON HLV_CLB
FOR INSERT 
AS
BEGIN
	DECLARE @vaitro NVARCHAR(100)
	SELECT @vaitro = VAITRO FROM inserted

	IF @vaitro IN (N'HLV Chính', N'HLV phụ', N'HLV thể lực', N'HLV thủ môn')
		BEGIN
			PRINT N'Phân công vai trò huấn luyện viên thành công'
		END
	ELSE
		ROLLBACK TRANSACTION
END;
-- exec
SELECT * FROM HLV_CLB;
INSERT INTO HLV_CLB(MAHLV, MACLB, VAITRO)
	   VALUES ('HLV01', 'TPY', N'HLV thủ môn');
SELECT * FROM HLV_CLB;

-- 8b. Kiểm tra mỗi câu lạc bộ chỉ có tối đa 2 HLV chính
CREATE TRIGGER trg8b ON HLV_CLB
FOR INSERT
AS
BEGIN
	DECLARE @maclb VARCHAR(5)
	SELECT @maclb = MACLB FROM inserted

	IF (SELECT COUNT(*) FROM HLV_CLB WHERE MACLB = @maclb AND VAITRO = N'HLV Chính' GROUP BY MACLB) <= 2
		BEGIN
			PRINT N'Phân công vai trò huấn luyện viên thành công'
		END
	ELSE
		ROLLBACK TRANSACTION
END;
SELECT * FROM HLV_CLB;
INSERT INTO HLV_CLB(MAHLV, MACLB, VAITRO)
	   VALUES ('HLV02', 'BBD', N'HLV Chính');
SELECT * FROM HLV_CLB;
	