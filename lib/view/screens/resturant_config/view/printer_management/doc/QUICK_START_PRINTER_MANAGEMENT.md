# Quick Start Guide - Printer Management

## 🚀 How to Access

### Option 1: Direct Navigation
```dart
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/printer_management/printer_management.dart';

// Navigate to printer management
Get.to(() => PrinterManagementScreen());
```

### Option 2: Using Route Helper
```dart
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';

// Navigate using route helper
Get.toNamed(RouteHelper.getPrinterManagementRoute());
```

---

## 📋 Quick Actions

### View Printer List
```dart
// Already loaded when screen opens
// Managed by PrinterManagementController
```

### Add New Printer
```dart
// Clear form and navigate
Get.find<PrinterManagementController>().clearForm();
Get.to(() => AddEditPrinterScreen(isEdit: false));
```

### Edit Printer
```dart
// Set printer to edit and navigate
controller.setEditingPrinter(printerObject);
Get.to(() => AddEditPrinterScreen(isEdit: true));
```

### Delete Printer
```dart
// Show confirmation dialog
Get.dialog(
  ConfirmationDialog(
    icon: Images.warning,
    description: 'Are you sure you want to delete this printer?',
    onYesPressed: () {
      controller.deletePrinter(printerId);
      Get.back();
    },
  ),
);
```

---

## 🎯 Printer Configuration Examples

### Example 1: Bluetooth Printer
```dart
Printer(
  areaName: "KDS",
  printerName: "thermal",
  printerType: "bluetooth",
  printerIp: "AB:0A:20:24:42:D3",  // MAC Address
  printerPaperRoll: 58,
  defaultPrinter: "1",
)
```

### Example 2: USB Printer
```dart
Printer(
  areaName: "Bill",
  printerName: "thermal",
  printerType: "usb",
  vendorId: "4070",
  productId: "33054",
  printerPaperRoll: 80,
  defaultPrinter: "1",
)
```

### Example 3: WiFi/LAN Printer
```dart
Printer(
  areaName: "BAR",
  printerName: "thermal",
  printerType: "online",
  wifiPrinterIp: "192.168.1.100",
  wifiPrinterName: "Kitchen_Printer",
  printerPaperRoll: 80,
  defaultPrinter: "0",
)
```

---

## 🎨 UI Components Reference

### Text Styles
```dart
// Headers
montserratSemiBold.copyWith(
  color: ColorTheme.black,
  fontSize: 20,
)

// Body Text
montserratMedium.copyWith(
  color: ColorTheme.grey1,
  fontSize: 15,
)

// Hints
montserratRegular.copyWith(
  color: ColorTheme.grey1,
  fontSize: 12,
)
```

### Colors
```dart
ColorTheme.appColor      // #F26B33 - Primary Orange
ColorTheme.blueColor     // #047DD4 - Blue
ColorTheme.redColor      // #F26B33 - Red
ColorTheme.greenColor    // #329937 - Green
ColorTheme.grey1         // #828282 - Grey
ColorTheme.borderGrey2   // #DCDCDC - Border
```

---

## 🔧 Controller Methods

### Initialize Controller
```dart
final controller = Get.find<PrinterManagementController>();
```

### Get Printer List
```dart
await controller.getPrinterList();
```

### Get Area Options
```dart
await controller.getAreaOptions();
```

### Add Printer
```dart
bool success = await controller.addPrinter();
if (success) {
  // Printer added successfully
}
```

### Update Printer
```dart
bool success = await controller.updatePrinter();
if (success) {
  // Printer updated successfully
}
```

### Delete Printer
```dart
await controller.deletePrinter(printerId);
```

### Set Printer Type
```dart
controller.setPrinterType('bluetooth');  // or 'usb' or 'wifi/lan'
```

### Clear Form
```dart
controller.clearForm();
```

---

## 📱 Integration in Settings Menu

### Add to Restaurant Settings
```dart
Container(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      _buildSettingTile(
        icon: Icons.print,
        title: 'Printer Management',
        subtitle: 'Configure restaurant printers',
        onTap: () => Get.toNamed(RouteHelper.getPrinterManagementRoute()),
      ),
      // Other settings...
    ],
  ),
)
```

### Build Setting Tile
```dart
Widget _buildSettingTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTheme.borderGrey2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorTheme.appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ColorTheme.appColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: montserratSemiBold.copyWith(fontSize: 15)),
                SizedBox(height: 4),
                Text(subtitle, style: montserratRegular.copyWith(
                  color: ColorTheme.grey1,
                  fontSize: 12,
                )),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: ColorTheme.grey1),
        ],
      ),
    ),
  );
}
```

---

## ✅ Testing Checklist

- [ ] Navigate to Printer Management screen
- [ ] View list of printers
- [ ] Add Bluetooth printer
- [ ] Add USB printer
- [ ] Add WiFi/LAN printer
- [ ] Edit existing printer
- [ ] Delete printer
- [ ] Toggle default printer
- [ ] Verify all fields save correctly
- [ ] Check error handling
- [ ] Test on different screen sizes

---

## 🐛 Troubleshooting

### Printer list is empty
```dart
// Check if API is returning data
print(controller.printerList.length);

// Manually trigger refresh
await controller.getPrinterList();
```

### Area options not loading
```dart
// Check area options
print(controller.areaOptions);

// Manually trigger refresh
await controller.getAreaOptions();
```

### Form not saving
```dart
// Check validation
print('Area: ${controller.selectedArea}');
print('Type: ${controller.selectedPrinterType}');
print('Paper Roll: ${controller.selectedPaperRoll}');
```

### Controller not found
```dart
// Ensure controller is initialized in get_di.dart
Get.lazyPut(() => PrinterManagementController(
  printerManagementRepo: Get.find()
));
```

---

## 📞 Support

For issues:
1. Check console logs for API errors
2. Verify authentication token
3. Check network connectivity
4. Validate API endpoint responses

---

**Ready to use! 🎉**

Navigate to the screen and start managing your printers!

