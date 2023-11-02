
-- Cleaining Data in SQL Queries

select * 
from PortfolioProject..NashvilleHousing
-----------------------------------------------------------------------------------

-----Standardize Date Format 
select SaleDate, CONVERT(Date,SaleDate),SaleDateConverted
from PortfolioProject..NashvilleHousing

 update NashvilleHousing
 set SaleDate = CONVERT(Date,SaleDate)-- it is not working that way ,you should alter a new column

 alter table NashvilleHousing
 add SaleDateConverted Date;

  update NashvilleHousing
 set SaleDateConverted = CONVERT(Date,SaleDate)

 ----------------------------------------------------------------------------------------------
 
 -----Populate Property Address Data

 select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null 

 select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,   ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b   
on a.ParcelID =b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where  a.PropertyAddress is  null 

update a
set PropertyAddress=  ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]  
where a.PropertyAddress is null

------------------------------------------------------------------------

---- Breaking out Address into İndividual Columns ( Address ,City , State)

 select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null first  way

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)as  address,

SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as city 
from PortfolioProject..NashvilleHousing 


alter table NashvilleHousing 
 add PropertySplitAddress Nvarchar(255);

  update NashvilleHousing
 set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)  


alter table NashvilleHousing
 add PropertySplitCity  nvarchar(255);

  update NashvilleHousing
 set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



--where PropertyAddress is null second way 


 Select 
 PARSENAME (REPLACE (OwnerAddress,',','.') ,3),
  PARSENAME (REPLACE (OwnerAddress,',','.') ,2),
   PARSENAME (REPLACE(OwnerAddress,',','.') ,1)
   From PortfolioProject.dbo. NashvilleHousing 



   alter table NashvilleHousing 
 add ownerSplitAddress Nvarchar(255);

  update NashvilleHousing
 set ownerSplitAddress =  PARSENAME (REPLACE (OwnerAddress,',','.') ,3)


alter table NashvilleHousing
 add ownerSplitCity nvarchar(255);

  update NashvilleHousing
 set ownerSplitCity =  PARSENAME (REPLACE (OwnerAddress,',','.') ,2)

 alter table NashvilleHousing
 add ownerSplitState nvarchar(255);

  update NashvilleHousing
 set ownerSplitState =  PARSENAME (REPLACE (OwnerAddress,',','.') ,1)

 select* 
 from NashvilleHousing

 -------------------------------------------------------------------------------------

 --- Change Y and N to Yes and No in 'Sold as Vacant' fild

 select Distinct(SoldAsVacant) , COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant 
,case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

---------------------------------------------------------------------------------

----Remove Dublicates
with RowNumCT as (
Select *, ROW_NUMBER() OVER ( 
							PARTITION BY
							 ParcelID, 
							 PropertyAddress,
							  SalePrice, 
							  SaleDate,
							   LegalReference 
							   ORDER BY 
							   UniqueID 
							   )  row_num 
	from PortfolioProject..NashvilleHousing)
	SELECT * 
	from RowNumCT
	where row_num>1


	------------------------------------------------------------------------------------------------------------
	

	----Delete Unused Columns
	select *
	from PortfolioProject..NashvilleHousing

	alter table  PortfolioProject..NashvilleHousing
	drop column OwnerAddress,TaxDistrict,propertyAddress,SaleDate	