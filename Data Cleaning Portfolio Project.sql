Select *
from NashvilleHousing


-- Standardizing the date format
Select SaleDate 
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
from NashvilleHousing


-- Populating Property Address data
Select *
from NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--- no more NULL PropertyAddress ---
Select *
from NashvilleHousing
order by ParcelID


-- Splitting addresses into individual columns - PropertyAddress (Address, City)
Select PropertyAddress
from NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--- cleaned city and address data added to the end of the table ---
Select *
from NashvilleHousing


-- Splitting addresses into individual columns - OwnerAddress (Address, City, State)
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--- cleaned city and address data added to the end of the table ---
Select *
from NashvilleHousing



-- Homogenize SoldAsVacant Column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   END
from NashvilleHousing
order by 1

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   END


	   
-- Removing Duplicates
WITH RowNumCTE AS(
Select *
	, ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from NashvilleHousing 
)

DELETE
from RowNumCTE
where row_num > 1



-- Deleting Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
from NashvilleHousing



