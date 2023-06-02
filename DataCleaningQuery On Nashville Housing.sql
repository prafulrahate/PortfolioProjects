-------------------------------------------------------------------
/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------

-- Let's Standardize data Format

Select SaleDate , Convert(Date,Saledate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,Saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,Saledate)

Select SaleDateConverted , Convert(Date,Saledate)
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------

--Populate Property Address data

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

-- But data also showing Null values in address
Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--But property address Cannot be empty as property owners can change but the property address cannot if it has a ParcelID or UniqueID

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

--Above data need to be changed -- put Property Address

Select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Above is Showing which Property address we need to populate

Select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Table 'a' update the data with Property address where Empty(NULL)

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---------------------------------------------------------------------

--Let's Break out Property address into Individual Columns as (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

-- Let's Add the Address and city to the Nashville Housing Table

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select * --- Let's See The results
From PortfolioProject.dbo.NashvilleHousing


------ Another way of spliting a string/column

-- Let's Do With OwnerAddress

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing
Where OwnerAddress is not null

Select
PARSENAME(Replace(OwnerAddress,',','.'), 3), -- Parsename runs in backwards direction in the string, for that, we have to start the column from 3rd section of the address ( that is 3,2,1)
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing

-- Now add the Owners Address into the table

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

Select * --- Let's See The results again
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------

-- Change Y/N and Yes/No in Column 'SoldAsVacant' 

-- First let's check the data
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

-- Data shows following result 
--Y	52
--N	    399
--Yes	4623
--No	51403

-- Now Change data to "Yes or No"
Select SoldAsVacant,
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant 
	End
From PortfolioProject.dbo.NashvilleHousing

-- Now update the table

Update NashvilleHousing
Set SoldAsVacant = Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant 
	End

-- Now check the table again
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

-- Now the updated result is 
-- Yes	4675
-- No	51802
----------------------------------------------------------------

-- Let's Remove the duplicates

With RowNumCTE as (
Select * ,
	Row_Number() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueId
				 ) row_num
	
From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- This is showing 104 Duplicate rows
-- Now lets Delete it

With RowNumCTE as (
Select * ,
	Row_Number() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueId
				 ) row_num
	
From PortfolioProject.dbo.NashvilleHousing
)

Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

-- Result shows - (104 rows affected) -- The duplicates are now deleted  - You Can check it by running previous query


------------------------------------------------------------------------------

-- Now Delete Unused Columns ## Usually do not delete or alter the raw data in the database ##
-- But, here, we are going to delete the unused columns 

-- First Check which coloumns we are not using
Select *
From PortfolioProject.dbo.NashvilleHousing
-- We will delete OwnerAddress and PropertyAddress as we have already created the split address for the same, TaxDistrict, SaleDate

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress,TaxDistrict, PropertyAddress, SaleDate

-- The columns has been deleted successfully, you can check it by running previous query

-----------------------------------END--------------------------------------------