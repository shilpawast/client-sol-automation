# OEM Quote Management & Vendor Follow-Up Automation – Power Automate Flow Overview

**Trigger:**  
- When an email arrives in the central quote intake mailbox.

## Steps

1. **Extract Customer Number & Quote Request**
   - Parse incoming email for customer number and quote details.
   - Extract attachments if present.

2. **Get Item Data from Data Lake**
   - Use Power Automate “Get Data” connector to query Azure Data Lake table.
   - Retrieve item details (Item No, UoM, Cost, Price, etc.).

3. **Auto-Populate Quote Excel Template**
   - Fill in fields of a stored Excel template (in OneDrive/SharePoint) with item data.
   - Save the populated file in a customer-specific folder.

4. **Pull Vendor Contacts**
   - Look up vendor contacts from a centralized repository (Excel or SharePoint List).
   - Fetch escalation contacts if needed.

5. **Send Initial Email to Vendor**
   - Use an email template to send the quote request.
   - Attach the populated quote file.

6. **Track Vendor Response**
   - Add/update “Vendor Responded – No Follow-Up Needed” field.
   - If vendor responds by phone/separate email, agent manually updates this field to suppress follow-up.

7. **Follow-Up & Escalation**
   - If no response in 48 hours, send follow-up email unless suppressed.
   - If no response in 72 hours, escalate to product manager.

---

## Exception Handling

- If vendor contact is missing, fallback to last known contact or escalate.
- Suppress automated emails until contact is confirmed.
- Log all exceptions and actions.

---

## Data Sources
- **Azure Data Lake:** Item master and quote data.
- **Excel/SharePoint List:** Vendor contacts.
- **Email:** Quote requests and vendor communication.

---

## Manual Agent Actions
- Update “Vendor Responded” field if contact is made outside email.
- Validate or update vendor info if missing.
