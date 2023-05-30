/*
	Display all date
*/

SELECT *
FROM PortFolioProject..NationalHousing


/*
	Date Formating
*/

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortFolioProject..NationalHousing


/*
update sale date in the database
*/

--UPDATE PortFolioProject..NationalHousing
--SET SaleDate = CONVERT(Date, SaleDate)

/* add new column to the table */
Alter table NationalHousing
Add SaleDateFormatted Date;

/* update the date in the new column added*/
update NationalHousing
set SaleDateFormatted = CONVERT(Date, SaleDate)


/*
Property address
*/

SELECT DB1.ParcelID, DB1.PropertyAddress, DB2.ParcelID, DB2.PropertyAddress, ISNULL(DB1.PropertyAddress, DB2.PropertyAddress)
FROM PortFolioProject..NationalHousing AS DB1
JOIN PortFolioProject..NationalHousing AS DB2
	ON DB1.ParcelID = DB2.ParcelID AND DB1.[UniqueID ]<> DB2.[UniqueID ]
WHERE DB1.PropertyAddress IS NULL

-- update the property address with null in database

UPDATE DB1
SET DB1.PropertyAddress = ISNULL(DB1.PropertyAddress, DB2.PropertyAddress)
FROM PortFolioProject..NationalHousing AS DB1
JOIN PortFolioProject..NationalHousing AS DB2
	ON DB1.ParcelID = DB2.ParcelID AND DB1.[UniqueID ]<> DB2.[UniqueID ]
WHERE DB1.PropertyAddress IS NULL


/*
breaking down the address
*/

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS COU
FROM PortFolioProject..NationalHousing

-- adding the address and city to the database

ALTER TABLE NationalHousing
ADD StreetAddress NVARCHAR(255);

ALTER TABLE NationalHousing
ADD City NVARCHAR(255);

UPDATE NationalHousing
SET StreetAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE NationalHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertyAddress ,StreetAddress, City
FROM PortFolioProject..NationalHousing

-- address breakdown using parsename

SELECT OwnerAddress
FROM PortFolioProject..NationalHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM PortFolioProject..NationalHousing

-- add owner breakdown address to table

ALTER TABLE NationalHousing
ADD Owner_StreetAddress NVARCHAR(255);

ALTER TABLE NationalHousing
ADD Owner_City NVARCHAR(255);

ALTER TABLE NationalHousing
ADD Owner_State NVARCHAR(255);

UPDATE NationalHousing
SET Owner_StreetAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NationalHousing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

UPDATE NationalHousing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


/*
using case statement to update the table
*/

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortFolioProject..NationalHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortFolioProject..NationalHousing

UPDATE NationalHousing
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

/*
remove duplicate entries
*/

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY 
						UniqueID
					 ) row_num
FROM PortFolioProject..NationalHousing
)

--SELECT *
--FROM RowNumCTE
--WHERE row_num >1
--ORDER BY PropertyAddress

DELETE 
FROM RowNumCTE
WHERE row_num >1


/*
remove unused columns
*/


ALTER TABLE NationalHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict