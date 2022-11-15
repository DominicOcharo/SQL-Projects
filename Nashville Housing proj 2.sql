-- Viewing the whole dataset
SELECT  *
  FROM PortfolioProject..NashvilleHousing

  --Standardize SaleDate column
  SELECT  SaleDate, CONVERT(DATE, SaleDate)
  FROM PortfolioProject..NashvilleHousing

  ALTER TABLE NashvilleHousing
  ADD SaleDateConverted DATE;

  UPDATE NashvilleHousing
  SET SaleDateConverted = CONVERT(DATE, SaleDate);

  SELECT SaleDateConverted, SaleDate
  FROM PortfolioProject..NashvilleHousing


  -- Populate property address data

   SELECT  *
  FROM PortfolioProject..NashvilleHousing
  WHERE PropertyAddress IS NULL

 SELECT  NS1.ParcelID, 
	NS1.PropertyAddress, 
	NS2.ParcelID,
	NS2.PropertyAddress
 FROM PortfolioProject..NashvilleHousing NS1
 JOIN PortfolioProject..NashvilleHousing NS2
	ON NS1.ParcelID = NS2.ParcelID
	AND NS1.[UniqueID ] != NS2.[UniqueID ]
WHERE NS1.PropertyAddress IS NULL 

UPDATE NS1
	SET PropertyAddress = ISNULL(NS1.PropertyAddress, NS2.PropertyAddress)
FROM NashvilleHousing NS1
JOIN NashvilleHousing NS2
	ON NS1.ParcelID = NS2.ParcelID
	AND NS1.[UniqueID ] != NS2.[UniqueID ]
WHERE NS1.PropertyAddress IS NULL

--Breaking property Address into three columns Address, City & State
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
	AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE NashvilleHousing
SET PropertySplitCity =
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing


-- Owner address splitting
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

 ALTER TABLE NashvilleHousing
 ADD OwnerSplitAddress VARCHAR(255);

 ALTER TABLE NashvilleHousing
 ADD OwnerSplitCity VARCHAR(255);

 ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255);

 UPDATE NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

 UPDATE NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

 UPDATE NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

 SELECT OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
FROM PortfolioProject..NashvilleHousing

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in SoldAsVacant Column
SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' 
		THEN 'Yes'
	WHEN SoldAsVacant = 'N'
		THEN 'No'
	ELSE SoldAsVacant
	END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

select *
FROM PortfolioProject..NashvilleHousing

-- Remove duplicates

WITH RowNumCTE AS (
 SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID)row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



WITH RowNumCTE AS (
 SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID)row_num
FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Delete Unused Column

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

SELECT *
FROM PortfolioProject..NashvilleHousing
