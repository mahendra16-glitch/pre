# Printer Management Implementation Guide

## Overview
A complete printer management system for MyGenie Restaurant App with CRUD operations, responsive UI, and multiple printer type support.

---

## Files Created

### 1. **Model Classes**
📄 `lib/data/model/response/printer_config_model.dart`
- `PrinterConfigModel` - Main response model
- `PrinterConfigData` - Data container
- `Printer` - Individual printer configuration
- `Role` - User role model
- `AreaOptionsModel` - Area options response
- `ApiResponse` - Generic API response

### 2. **Repository**
📄 `lib/view/screens/resturant_config/repo/printer_management_repo.dart`
- `getPrinterList()` - Fetch all printers
- `getAreaOptions()` - Fetch area/station options
- `addPrinter(Printer)` - Add new printer
- `updatePrinter(Printer)` - Update existing printer
- `deletePrinter(int id)` - Delete printer by ID

### 3. **Controller**
📄 `lib/view/screens/resturant_config/controller/printer_management_controller.dart`
- State management using GetX
- Form controllers for all input fields
- CRUD operations with loading states
- Dropdown value management
- Form validation

### 4. **UI Screens**

#### Printer List Screen
📄 `lib/view/screens/resturant_config/view/printer_management/printer_management.dart`

**Features:**
- ✅ Responsive header with column labels
- ✅ Card-based list view with printer details
- ✅ Color-coded printer types (Bluetooth: Blue, USB: Green, WiFi: Orange)
- ✅ Edit and delete action buttons
- ✅ Empty state with helpful message
- ✅ Floating action button to add new printer
- ✅ Loading indicator
- ✅ Confirmation dialog for delete action

**UI Elements:**
```
Header: [Area Name | Printer Type | Paper Roll | Actions]
Cards: Display printer info with visual badges
Actions: Edit (Blue) | Delete (Red)
```

#### Add/Edit Printer Screen
📄 `lib/view/screens/resturant_config/view/printer_management/add_edit_printer.dart`

**Features:**
- ✅ Two expansion tiles (Basic & Advanced)
- ✅ Conditional field rendering based on printer type
- ✅ Professional rounded input fields
- ✅ Color-coded sections
- ✅ Loading state on submit button

**Form Structure:**

**Basic Configuration (Orange Icon):**
- Printer Mode dropdown: [fixed, waiter, station]

**Advanced Configuration (Blue Icon):**
1. **Printer For** - Dropdown with all available areas/stations
2. **Printer Type** - Dropdown [bluetooth, usb, wifi/lan]
3. **Conditional Fields:**
   - **Bluetooth:** Android IP/MAC Address field
   - **USB:** Printer Name, Product ID, Vendor ID fields
   - **WiFi/LAN:** Printer Name, Printer IP fields
4. **Paper Roll Size** - Dropdown [58mm, 80mm]
5. **Default Printer** - Toggle switch

---

## API Endpoints

### Base URL
```
https://preprod.mygenie.online
```

### Endpoints

#### 1. Get Printer List
```http
GET /api/v2/vendoremployee/restaurant-settings/printer-config
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Printer configuration retrieved successfully",
  "data": {
    "printers": [...],
    "roles": [...],
    "restaurant_id": 478
  }
}
```

#### 2. Get Area Options
```http
GET /api/v2/vendoremployee/restaurant-settings/printer-config/area-options
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Area options retrieved successfully",
  "data": {
    "options": ["Bill", "Waiter", "captain", "KDS", "BAR", ...]
  }
}
```

#### 3. Add Printer
```http
POST /api/v2/vendoremployee/restaurant-settings/printer-config
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "area_name": "Bill",
  "printer_name": "thermal",
  "printer_ip": "192.168.1.100",
  "printer_paper_roll": 80,
  "printer_type": "online",
  "mac_printer_ip": "192.168.1.101",
  "vendor_id": "1234",
  "product_id": "5678",
  "default": "1",
  "wifi_printer_ip": "192.168.1.102",
  "wifi_printer_name": "Kitchen_Printer"
}
```

#### 4. Update Printer
```http
POST /api/v2/vendoremployee/restaurant-settings/printer-config
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:** (Same as Add with `id` field)
```json
{
  "id": 743,
  "area_name": "Bill",
  ...
}
```

#### 5. Delete Printer
```http
DELETE /api/v2/vendoremployee/restaurant-settings/printer-config/{id}
Authorization: Bearer {token}
```

---

## Integration Steps

### 1. Dependency Injection
Already configured in `lib/helper/get_di.dart`:

```dart
// Repository
Get.lazyPut(() => PrinterManagementRepo(apiClient: Get.find()));

// Controller
Get.lazyPut(() => PrinterManagementController(printerManagementRepo: Get.find()));
```

### 2. Navigation

**To Printer List:**
```dart
Get.to(() => PrinterManagementScreen());
```

**To Add Printer:**
```dart
Get.find<PrinterManagementController>().clearForm();
Get.to(() => AddEditPrinterScreen(isEdit: false));
```

**To Edit Printer:**
```dart
controller.setEditingPrinter(printerObject);
Get.to(() => AddEditPrinterScreen(isEdit: true));
```

---

## UI Design Highlights

### Color Scheme
- **Primary Orange:** `#F26B33` - Main actions, app color
- **Blue:** `#047DD4` - Edit actions, advanced section
- **Red:** `#F26B33` - Delete actions
- **Green:** `#329937` - USB printer type
- **Grey:** `#828282` - Secondary text

### Typography
- **Headers:** Montserrat SemiBold (20px)
- **Body:** Montserrat Medium (14-15px)
- **Hints:** Montserrat Regular (12-14px)

### Border Radius
- **Cards:** 12px
- **Input Fields:** 30px (fully rounded)
- **Buttons:** 8-30px

### Shadows
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.04),
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

---

## Responsive Features

1. **Flexible Layout:** Uses `Expanded` widgets with flex ratios
2. **Scrollable Content:** `SingleChildScrollView` for forms
3. **ListView:** Optimized list rendering with padding
4. **Screen Adaptation:** Works on mobile, tablet, desktop

---

## Validation

The controller performs validation for:
- ✅ Area selection (required)
- ✅ Printer type selection (required)
- ✅ Paper roll size selection (required)
- ✅ Shows error snackbars for missing fields

---

## Features Summary

### ✨ User Experience
- Intuitive two-section form (Basic & Advanced)
- Conditional field rendering
- Visual feedback with colors and icons
- Empty states with helpful messages
- Loading indicators
- Confirmation dialogs

### 🎨 Design
- Professional, modern UI
- Consistent color scheme
- Rounded corners and soft shadows
- Icon-based visual hierarchy
- Responsive layout

### 🔧 Technical
- GetX state management
- Repository pattern
- Model-based data handling
- Error handling with user feedback
- Lazy loading with dependency injection

---

## Example Usage in App

Add to your restaurant settings menu:

```dart
ListTile(
  leading: Icon(Icons.print, color: ColorTheme.appColor),
  title: Text('Printer Management', style: montserratMedium),
  subtitle: Text('Configure restaurant printers', style: montserratRegular),
  trailing: Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () => Get.to(() => PrinterManagementScreen()),
)
```

---

## Testing Checklist

- [ ] List displays all printers from API
- [ ] Area options load correctly
- [ ] Add new printer (Bluetooth)
- [ ] Add new printer (USB)
- [ ] Add new printer (WiFi/LAN)
- [ ] Edit existing printer
- [ ] Delete printer with confirmation
- [ ] Toggle default printer switch
- [ ] Conditional fields show/hide correctly
- [ ] Form validation works
- [ ] Loading states display
- [ ] Error messages appear
- [ ] Success messages appear
- [ ] Navigation works correctly
- [ ] UI is responsive on different screens

---

## Future Enhancements

1. **Search/Filter:** Add search bar for printer list
2. **Test Print:** Add "Test Print" button for each printer
3. **Printer Status:** Show online/offline status with indicator
4. **Bulk Actions:** Select multiple printers for batch operations
5. **Print Preview:** Preview print output before saving
6. **Import/Export:** Export printer configurations as JSON
7. **Printer Templates:** Save and reuse printer configurations

---

## Support

For issues or questions:
1. Check API responses in debug console
2. Verify authentication token is valid
3. Ensure network connectivity
4. Check printer configuration values match API requirements

---

## Credits

**Developer:** AI Assistant  
**Date:** November 19, 2024  
**Framework:** Flutter with GetX  
**Design Pattern:** MVC + Repository Pattern

---

**End of Documentation**

