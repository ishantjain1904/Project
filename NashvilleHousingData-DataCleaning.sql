  --UPDATE DATE
  SELECT SaleDate,CONVERT(DATE,SaleDate) 
  FROM [dbo].[NashvilleHouse]

  ALTER TABLE [dbo].[NashvilleHouse]
  ADD SaleDateConverted DATE;

  UPDATE NashvilleHouse 
  SET SaleDateConverted=CONVERT(date,SaleDate);

--POPULATE PROPERTY ADRESS DATA
SELECT * [SQL_PROJECT].[dbo].[NashvilleHouse]
ORDER BY ParcelID

SELECT A.ParcelID,A.PropertyAddress,
B.ParcelID,B.PropertyAddress,
ISNULL(A.PropertyAddress,B.PropertyAddress)
[SQL_PROJECT].[dbo].[NashvilleHouse] AS A
JOIN NashvilleHouse AS B
ON A.ParcelID=B.ParcelID
AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress=ISNULL(A.PropertyAddress,B.PropertyAddress)
[SQL_PROJECT].[dbo].[NashvilleHouse] AS A
JOIN NashvilleHouse AS B
ON A.ParcelID=B.ParcelID
AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--GETTING COLUMNS FROM ADDRESS
SELECT PropertyAddress [SQL_PROJECT].[dbo].[NashvilleHouse]
   --ORDER BY ParcelID

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS ADDRESS,
 --CHARDINDEX RETURNS POSITION OF ',' IN COLUMN 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS LENGTHADDRESS 
[SQL_PROJECT].[dbo].[NashvilleHouse]

ALTER TABLE [SQL_PROJECT].[dbo].[NashvilleHouse]
ADD PropertySplitAddress NVARCHAR(255)
ALTER TABLE [SQL_PROJECT].[dbo].[NashvilleHouse]
ADD PropertySplitCity NVARCHAR(255)

UPDATE [SQL_PROJECT].[dbo].[NashvilleHouse]
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
UPDATE [SQL_PROJECT].[dbo].[NashvilleHouse]
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) 



--OWNER ADDRESS
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 --INDEXING BACKWARD
FROM SQL_PROJECT.[dbo].[NashvilleHouse]

ALTER TABLE [SQL_PROJECT].[dbo].[NashvilleHouse]
ADD OwnerSplitAddress NVARCHAR(255)
ALTER TABLE [SQL_PROJECT].[dbo].[NashvilleHouse]
ADD OwnerSplitCity NVARCHAR(255)
ALTER TABLE [SQL_PROJECT].[dbo].[NashvilleHouse]
ADD OwnerSplitState NVARCHAR(255)

UPDATE [SQL_PROJECT].[dbo].[NashvilleHouse]
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE [SQL_PROJECT].[dbo].[NashvilleHouse]
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE [SQL_PROJECT].[dbo].[NashvilleHouse]
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT DISTINCT(SoldAsVacant),
COUNT(*)
[SQL_PROJECT].[dbo].[NashvilleHouse]
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE 
    WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
[SQL_PROJECT].[dbo].[NashvilleHouse]

UPDATE NashvilleHouse
SET SoldAsVacant=CASE 
    WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END

--REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,PropertyAddress,
SalePrice,SaleDate,
LegalReference
ORDER BY UniqueID
) AS ROW_NUM
FROM SQL_PROJECT.dbo.NashvilleHouse
--ORDER BY ParcelID
)
DELETE   
FROM RowNumCTE
WHERE ROW_NUM>1

SELECT *
FROM RowNumCTE
WHERE ROW_NUM>1
--ORDER BY PropertyAddress

--DELETE UNUSED COLUMNS
SELECT * 
FROM SQL_PROJECT.dbo.NashvilleHouse


ALTER TABLE SQL_PROJECT.dbo.NashvilleHouse
DROP COLUMN SaleDate,OwnerAddress,
TaxDistrict,
PropertyAddress


