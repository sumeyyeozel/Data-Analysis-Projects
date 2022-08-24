/*Cleaning Data*/
Select *
From NashvilleHousing

--Standardize Data Format

Select SaleDate, CONVERT(date,SaleDate)
From NashvilleHousing

--update NashvilleHousing
--set SaleDate = CONVERT(date,SaleDate) 

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

Select SaleDateConverted, CONVERT(date,SaleDate)
From NashvilleHousing

-- Populate Property Adress Data

Select *
From NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--self join
Select nash.ParcelID, nash.PropertyAddress, vil.ParcelID, vil.PropertyAddress, ISNULL(nash.PropertyAddress, vil.PropertyAddress)
from NashvilleHousing nash
join NashvilleHousing vil
  on nash.ParcelID= vil.ParcelID
  and nash.[UniqueID ] <> vil.[UniqueID ]
where nash.PropertyAddress is null

Update nash
set PropertyAddress =  ISNULL(nash.PropertyAddress, vil.PropertyAddress)
from NashvilleHousing nash
join NashvilleHousing vil
  on nash.ParcelID= vil.ParcelID
  and nash.[UniqueID ] <> vil.[UniqueID ]
where nash.PropertyAddress is null

select PropertyAddress
from NashvilleHousing
where PropertyAddress is null


--Breaking out Adress into Individual Columns(Adress, City, State)
select PropertyAddress
FROM NashvilleHousing

--select
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adress
--,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
--from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAdress nvarchar(255);

update NashvilleHousing
set  PropertySplitAdress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from NashvilleHousing

select OwnerAddress
from NashvilleHousing

--Select
--PARSENAME(replace(OwnerAddress,',', '.'),3)
--,PARSENAME(replace(OwnerAddress,',', '.'),2)
--,PARSENAME(replace(OwnerAddress,',', '.'),1)
--FROM NashvilleHousing  --easier than substring

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',', '.'),3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',', '.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',', '.'),1)

select *
from NashvilleHousing

--Change Y and N to Yes and No in 'Sold ass Vacant' field
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant

select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
   when SoldAsVacant ='N' then 'No'
   else SoldAsVacant
   end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
   when SoldAsVacant ='N' then 'No'
   else SoldAsVacant
   end

--Remove Duplicates
with RowNumCTE AS(
Select *, 
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
 PropertyAddress,
 SalePrice,
 SaleDate,
 LegalReference
 order by UniqueID) row_num
from NashvilleHousing
)

--DELETE
select *
FROM RowNumCTE
where row_num>1


--Delete Unused Columns
select *
from NashvilleHousing

alter table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate