/*

Clean the data

*/
-- Dataset
Select*
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------

--See a summary of Type of Land Use


Select
	Distinct(LandUse) as TypeOfLandUse,
	Count(LandUse)
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE LandUse = 'VACANT RESIENTIAL LAND'
GROUP BY LandUse
ORDER BY TypeOfLandUse

--Update VACANT RESIENTIAL LAND with VACANT RESIDENTIAL VALUE (typo error)
Update NashvilleHousing
SET 
	LandUse = 'VACANT RESIDENTIAL VALUE'
WHERE LandUse = 'VACANT RESIENTIAL LAND'

--Update
Update NashvilleHousing
SET 
	LandUse = 'VACANT RESIDENTIAL LAND'
WHERE LandUse = 'VACANT RES LAND'

-----------------------------------------------------------------------------------------------------------------------------

--Standardized Date Format
SELECT 
	CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET 
	SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

Update NashvilleHousing
SET 
	SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT 
	a.[UniqueID ],
	a.ParcelID,
	a.PropertyAddress,
	b.[UniqueID ],
	b.ParcelID,
	b.PropertyAddress
FROM NashvilleHousing a
INNER JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Using CASE to update the table
UPDATE a
SET
	PropertyAddress = CASE
	WHEN a.PropertyAddress is null then b.PropertyAddress
	ELSE a.propertyAddress
	END
FROM NashvilleHousing a
INNER JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--USING ISNULL to update the table
UPDATE a
SET
	PropertyAddress = ISNULL(b.PropertyAddress, a.Propertyaddress)
FROM NashvilleHousing a
INNER JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null	

-----------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) +2), LEN(PropertyAddress))
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255),
	PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) +2), LEN(PropertyAddress))



SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) State
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET 
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-----------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant

Select 
	CASE 
		When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = 
	CASE 
		When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
-----------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates
--Finding the Duplicates
WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) RowNum
FROM PortfolioProject.dbo.NashvilleHousing)
SELECT*
FROM RowNumCTE
WHERE RowNum > 1

--Delete those 104 Rows
WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) RowNum
FROM PortfolioProject.dbo.NashvilleHousing)
Delete 
FROM RowNumCTE
WHERE RowNum > 1


-----------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

Select*
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict











