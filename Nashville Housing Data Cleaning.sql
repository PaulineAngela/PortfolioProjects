/*

Data Cleaning Nashville Housing

*/

Select *
From Portfolio1..NashvilleHousing


--Standardize date format

Select SaleDate, CONVERT(Date,SaleDate)
From Portfolio1..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data

Select *
From Portfolio1..NashvilleHousing
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio1..NashvilleHousing a
Join Portfolio1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio1..NashvilleHousing a
Join Portfolio1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


--Separating address into individual columns (Address, City, State)

Select PropertyAddress
From Portfolio1..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From Portfolio1..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From Portfolio1..NashvilleHousing


Select OwnerAddress
From Portfolio1..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3),
PARSENAME(Replace(OwnerAddress, ',', '.') ,2),
PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
From Portfolio1..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)


Select *
From Portfolio1..NashvilleHousing


--Change Y and N to Yes and No in "SoldAsVacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio1..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
From Portfolio1..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END


--Remove Duplicates

WITH RowNumCTE AS(
Select *,
		ROW_NUMBER() Over(
		Partition by ParcelID,
					 SaleDate,
					 PropertyAddress,
					 SalePrice,
					 LegalReference
					 Order by UniqueID
							 ) row_num

From Portfolio1..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From Portfolio1..NashvilleHousing


--Delete Unused Columns

Select *
From Portfolio1..NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
