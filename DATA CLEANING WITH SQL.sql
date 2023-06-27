/****** Script for cleaning data in SQL******/

select *
from dbo.[Tennessee Housing]
-------------------------------------------------------------------------

/******Standardize sale date format******/
select saleDATE,CONVERT(Date,saleDate)
from [Tennessee Housing]

ALTER TABLE [Tennessee Housing]
Add saleDateConverted Date;

UPDATE [Tennessee Housing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted,CONVERT(Date,SaleDate)
from dbo.[Tennessee Housing]

-------------------------------------------------------------------------
/****** populate property address data******/
select *
from dbo.[Tennessee Housing]
--where PropertyAddress is null--
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
from dbo.[Tennessee Housing] a
JOIN dbo.[Tennessee Housing] b
    ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
from dbo.[Tennessee Housing] a
JOIN dbo.[Tennessee Housing] b
    ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------
/****** change Y and N to YES and NO in "sold as a vancant" field ******/


select DISTINCT (SoldAsVacant),COUNT (SoldAsVacant)
from dbo.[Tennessee Housing]
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
from dbo.[Tennessee Housing]

UPDATE [Tennessee Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END

-------------------------------------------------------------------------
/****** Breaking out address into individual column (Address,city,state)script******/

Select OwnerAddress
from dbo.[Tennessee Housing]

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from dbo.[Tennessee Housing]

ALTER TABLE [Tennessee Housing]
Add OwnerSplitAddress Nvarchar(255);

UPDATE [Tennessee Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE [Tennessee Housing]
Add OwnerSplitCity Nvarchar(255);

UPDATE [Tennessee Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE [Tennessee Housing]
Add OwnerSplitState Nvarchar(255);

UPDATE [Tennessee Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

-------------------------------------------------------------------------

/******Remove Duplicate ******/
WITH RowNumCTE AS(
SELECT *,
      ROW_NUMBER () OVER (
	  PARTITION BY ParcelID,
					PropertyAddress,
					Saleprice,
					SaleDate,
					LegalReference
					ORDER BY
					    UniqueID
						) row_num
from dbo.[Tennessee Housing]
--ORDER BY ParcelID--
)
DELETE 
from RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress--
-------------------------------------------------------------------------

/******delete used columns******/

SELECT *
FROM [Tennessee Housing]

ALTER TABLE [Tennessee Housing]
DROP COLUMN Taxdistrict,SaleDate

-------------------------------------------------------------------------