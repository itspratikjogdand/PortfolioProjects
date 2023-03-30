-- Cleaning Data in SQL queries

SELECT * 
FROM portfolio_project..NashvilleHousing


-- Standerdising Date format

SELECT SaleDate, CONVERT(date,SaleDate)
FROM portfolio_project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD sale_date_converted DATE;

UPDATE NashvilleHousing
SET sale_date_converted = CONVERT(date,SaleDate)



--Populate property address data

SELECT *
FROM portfolio_project..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio_project..NashvilleHousing a
JOIN portfolio_project..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio_project..NashvilleHousing a
JOIN portfolio_project..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out address into individual columns(Adress,city,state)

SELECT PropertyAddress
FROM portfolio_project..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM portfolio_project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD property_split_address NVARCHAR(255);


UPDATE NashvilleHousing
SET property_split_address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD property_split_city NVARCHAR(255);

UPDATE NashvilleHousing
SET property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT property_split_city,property_split_address
FROM portfolio_project..NashvilleHousing

SELECT * 
FROM portfolio_project..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN Address,City;



SELECT OwnerAddress 
FROM portfolio_project..NashvilleHousing
 
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM portfolio_project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD owner_split_address NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_split_address = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE NashvilleHousing
ADD owner_split_city NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_split_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD owner_split_state NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_split_state = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

SELECT * 
FROM portfolio_project..NashvilleHousing


--Select Y and N to Yes and No in "sold as vacant" feild

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM portfolio_project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	 END AS SoldAsVacant1
FROM portfolio_project..NashvilleHousing

UPDATE portfolio_project..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	 END


--Remove Duplicates Uing CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				ORDER BY UniqueID
				) row_num

	
FROM portfolio_project..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				ORDER BY UniqueID
				) row_num

	
FROM portfolio_project..NashvilleHousing
--ORDER BY ParcelID
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress




--DELETE UNUSED COLUMNS


SELECT * 
FROM portfolio_project..NashvilleHousing

ALTER TABLE portfolio_project..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE portfolio_project..NashvilleHousing
DROP COLUMN SaleDate