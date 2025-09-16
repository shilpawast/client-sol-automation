# Excel Template Structure for Quote Generation

## Template Layout

### Customer Information Section (Rows 1-6)
```
A1: OEM Quote Request
B2: Customer Number: [DYNAMIC]
B3: Customer Name: [DYNAMIC]
B4: Request Date: [DYNAMIC]
B5: Quote ID: [DYNAMIC]
```

### Item Details Section (Starting Row 8)
```
A7: Item No. | B7: Description | C7: UoM | D7: Qty | E7: Unit Cost | F7: Unit Price | G7: Total
```

### Vendor Information Section (Top Right)
```
F2: Vendor: [DYNAMIC]
F3: Contact: [DYNAMIC]  
F4: Email: [DYNAMIC]
```

## Dynamic Fields Mapping

```json
{
  "customerInfo": {
    "customerNumber": "B2",
    "customerName": "B3", 
    "requestDate": "B4",
    "quoteId": "B5"
  },
  "itemDetails": {
    "startRow": 8,
    "columns": {
      "itemNumber": "A",
      "description": "B", 
      "unitOfMeasure": "C",
      "quantity": "D",
      "unitCost": "E",
      "unitPrice": "F",
      "totalPrice": "G"
    }
  },
  "vendorInfo": {
    "vendorName": "F2",
    "vendorContact": "F3",
    "vendorEmail": "F4"
  },
  "summary": {
    "subtotal": "G50",
    "tax": "G51", 
    "total": "G52"
  }
}
```

## Sample Data Population

### Customer: ABC123
- Customer Name: ABC Manufacturing Corp
- Request Date: 2024-01-15
- Quote ID: Q20240115-a1b2c3d4

### Items:
1. Item: PUMP-001, Desc: Hydraulic Pump, UoM: EA, Cost: $450.00, Price: $675.00
2. Item: VALVE-002, Desc: Control Valve, UoM: EA, Cost: $125.00, Price: $187.50
3. Item: FILTER-003, Desc: Oil Filter, UoM: EA, Cost: $25.00, Price: $37.50

### Vendor:
- Vendor: Industrial Supplies Inc
- Contact: John Smith
- Email: john.smith@industrialsupplies.com

## Excel Formulas

### Total Price Calculation
```excel
=D8*F8  // Quantity * Unit Price
```

### Subtotal
```excel  
=SUM(G8:G47)  // Sum of all total prices
```

### Tax (8.5%)
```excel
=G50*0.085  // Subtotal * Tax Rate
```

### Grand Total
```excel
=G50+G51  // Subtotal + Tax
```

## Power Automate Integration

### Template Update Actions
1. **Get Excel Table**: Connect to template file
2. **Update Customer Info**: Populate B2:B5
3. **Update Vendor Info**: Populate F2:F4  
4. **Add Item Rows**: Loop through items and populate starting at row 8
5. **Calculate Totals**: Trigger formula recalculation
6. **Save As New File**: Create customer-specific copy

### Error Handling
- Validate template exists before processing
- Check for required fields completion
- Verify formula calculations
- Handle file lock scenarios
- Log template processing errors

This structure provides a professional quote template that integrates seamlessly with the Power Automate flow for automated document generation.