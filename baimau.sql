Create table NHACUNGCAP (
Manhacc varchar (10) primary key ,
TennhaCC nvarchar(50) ,
DiaChi nvarchar (100),
Sodt nvarchar (50),
Masothue varchar (10)
)
create table LOAIDICHVU(
MaLoaiDv varchar(10) primary key,
tenlaoidv nvarchar (50),
)
Create table MucPhi (
MaMp varchar(10) primary key,
Dongia int ,
Mota nvarchar (50)
)
go
create table DONGXE (
DongXe nvarchar(50) primary key,
Hangxe nvarchar (50) ,
SoChoNgoi int
)
go
create proc sp_11 (@DongXe nvarchar(50) ,
@Hangxe nvarchar (50) ,
@SoChoNgoi int
)
as 
begin
insert into DONGXE values (@DongXe  ,
@Hangxe ,
@SoChoNgoi )
end
go 
sp_11 'lili','Toyota','16'
go


create table Dangkycungcap(
Madkcc varchar (10) primary key,
Manhacc varchar (10) FOREIGN KEY (Manhacc) REFERENCES NHACUNGCAP(Manhacc),
MaLoaiDv varchar(10) FOREIGN KEY (MaLoaiDv) REFERENCES LOAIDICHVU(MaLoaiDv),
DongXe nvarchar(50) FOREIGN KEY (DongXe) REFERENCES  DONGXE(DongXe),
MaMp varchar(10) FOREIGN KEY (MaMp) REFERENCES  MucPhi(MaMp),
NgayBatDaucungcap date,
NgayKethuccungcap date
)
go
insert into NHACUNGCAP values ('NCC001','cty tnhh toàn pháp','hai chau','05511399988','568941'),
('NCC002','cty co phần đong du','lien chieu','05511399890','456789'),
('NCC003','ông Nguyễn Van A','Hoa thuan','055113999890','321456'),
('NCC004','Cty cổ phần toàn cầu xanh','hai chau','055113998945','513364')
go
insert into LOAIDICHVU values 
('DV01','dich vu xe taxi'),
('DV02','dich vụ xe buýt công cộng theo chuyến cố địch'),
('DV03','dịch vụ cho thuê xe theo hợp đồng')

go 
insert into MucPhi values 
('MP01','10000','áp dụng từ 1/2015'),
('MP02','15000','áp dụng từ 2/2015'),
('MP03','20000','áp dụng từ 1/2010'),
('MP04','25000','áp dụng từ 2/2011')
go
insert into DONGXE values
('Hiace','Toyota','16'),
('Vios','Toyota','5'),
('escape','Ford','5'),
('Cersto','KIA','7'),
('Forte','KIA','5')
insert into Dangkycungcap values
('DK001','NCC001','DV01','Hiace','MP01','2015-11-20','2016-11-20')
insert into Dangkycungcap values
('DK002','NCC002','DV02','Vios','MP02','2015-11-20','2017-11-20'),
('DK003','NCC003','DV03','escape','MP03','2017-11-20','2018-11-20')
go
--cau1 
Create view V_Nhacungcap 
as
select TennhaCC ,DiaChi ,Sodt ,Masothue from NHACUNGCAP a inner join Dangkycungcap b on a.Manhacc=b.Manhacc
where DiaChi='lien chieu' and NgayBatDaucungcap ='2015-11-20'
go
select * from V_Nhacungcap
--cau 1.2
update V_Nhacungcap set DiaChi='Thanh khe'
--cau 2
go 
create proc sp_1 (@DongXe nvarchar(50))
as
begin
delete from DONGXE where @DongXe=DongXe
end
go
sp_1 'Vios'
--cau 2.2
go
create proc sp_3 (
@Madkcc varchar (10),
@Manhacc varchar (10) ,
@MaLoaiDv varchar(10) ,
@DongXe nvarchar(50) ,
@MaMp varchar(10) ,
@NgayBatDaucungcap date,
@NgayKethuccungcap date)
as 
begin
if  exists ( select  Madkcc from Dangkycungcap WHERE Madkcc=@Madkcc)
begin
    PRINT N'mã này đã có, nhập mã khác'
	RETURN -1
END
  if  not exists (
  select  Manhacc from NHACUNGCAP WHERE Manhacc=@Manhacc)
  begin
    PRINT N'không tìm thấy nhà cung cấp'
	RETURN -1
END
  
  if  not exists (
  select  MaLoaiDv from LOAIDICHVU WHERE MaLoaiDv=@MaLoaiDv)
  begin
    PRINT N'không có laoji dịch vụ này'
	RETURN -1
END
  if
  not exists (
  select  DongXe from DONGXE WHERE DongXe=@DongXe)
  begin
    PRINT N'không có dòng xe này'
	RETURN -1
END
  if not exists (
      select  MaMp from MucPhi WHERE MaMp=@MaMp)
	  begin
    PRINT N'không có mức phí này'
	RETURN -1
END
insert into Dangkycungcap values (@Madkcc ,
@Manhacc  ,
@MaLoaiDv  ,
@DongXe  ,
@MaMp,
@NgayBatDaucungcap ,
@NgayKethuccungcap )
end
go
sp_3 'DK004','NCC004' , 'DV03','Cersto','MP04','2017-11-20','2018-11-20'
go
--câu 3
create trigger xoa on Dangkycungcap for delete 
as 
begin
 declare @tong int
 select @tong = count(Madkcc) from Dangkycungcap

 print 'bản con'+ cast(@tong as varchar (50))
 end
 go
 delete from Dangkycungcap WHERE Madkcc='DK003'
 ---câu 3.2
 GO
 
 
go
CREATE TRIGGER Trigger_2
ON Dangkycungcap
FOR UPDATE
AS
BEGIN
	IF UPDATE(NgayKetThucCungCap)
	BEGIN
		DECLARE @ngaybatdau date, @ngayketthuc date
		SELECT @ngaybatdau = NgayBatDauCungCap, @ngayketthuc = NgayKethuccungcap
		FROM inserted 
		
		IF(DATEDIFF(DAY,@ngaybatdau,@ngayketthuc) > 4*365)
		BEGIN
			PRINT N'Khoảng thời gian đăng ký cung cấp phương tiện tính từ ngày bắt đầu cung cấp đến hết ngày kết thúc cung cấp phải nhỏ hơn 4 năm'
			ROLLBACK TRANSACTION
		END	
	END
END
go

go
drop trigger ngay34
---câu4

go
CREATE FUNCTION func1()
RETURNS int
AS
BEGIN
	DECLARE @tong int
	SELECT @tong = SUM(SoLuongXeDangKy) 
	FROM Dangkycungcap
	WHERE MaMP = (SELECT MaMP FRom MucPhi WHERE Dongia = 10000)
	RETURN @tong
END
GO
go
--4b
  go

CREATE FUNCTION func2 (@mancc char(6))
RETURNS int
AS
BEGIN
	DECLARE @kq int
	SELECT @kq = MAX(DATEDIFF(day,NgayBatDaucungcap,NgayKethuccungcap))
	FROM Dangkycungcap
	WHERE MaNhaCC = @mancc 
	RETURN @kq
END
GO
select dbo.func2('NCC001')
--- câu thêm tăng lên 1
go
CREATE TRIGGER Trg_SVINSERT ON  Dangkycungcap 
FOR INSERT
AS
IF NOT EXISTS(SELECT * FROM DMLOP, INSERTED WHERE DMLOP.MaLop=INSERTED.MaLop)
ROLLBACK TRANSACTION
ELSE
UPDATE DMLOP SET DMLOP.Siso=DMLOP.Siso+1FROM INSERTED
WHERE DMLOP.MaLop=INSERTED.MaLop