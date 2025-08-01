# OEM Quote Management & Vendor Follow-Up Automation – Project Notes

## Chat Summary & Planning

### Project Requirements
- Automate OEM quote management and vendor follow-up
- Must-haves:
  1. Customer forwards quote request to central email box (include customer no.)
  2. System parses request and extracts item data
  3. Quote template is auto-populated from Data Lake table
  4. Vendor contacts are pulled from repository
  5. Initial email sent to vendor with quote request
  6. If vendor responds via phone/separate email, agent updates “Vendor Responded – No Follow-Up Needed” field

### Tech Stack Choice
- Power Automate cloud flows
- Data source: Azure Data Lake (using "Get Data" from table)
- Vendor repository: Excel file or SharePoint List
- Quote template: Excel
- Email automation: Outlook/Exchange

---

## Helpful Steps

### GitHub Repository Creation
1. Sign up/log in to GitHub
2. Create a new repository (public/private, add README)
3. Upload files via web (drag/drop or choose files)
4. Organize files in folders
5. Add collaborators if needed
6. (Optional) Use GitHub Desktop for bulk uploads

### Conversation Preservation
- This chat is NOT auto-saved on GitHub; paste this file into your repo for future reference!

---

## Next Steps (from Assistant)
1. Prepare Power Automate flow overview (diagram and pseudo-steps)
2. Provide .json export example for Power Automate flow
3. Sample Excel template for quote population
4. Example vendor contact repository file
5. Sample email templates (initial, follow-up, escalation)

### Info Needed from User
- Central mailbox address/type (Exchange/Outlook)
- Azure Data Lake table name/schema (columns for item master)
- Existing Excel quote template or need a new sample
- Vendor contact repository format (Excel or SharePoint List)
- Email template wording/branding preferences
- Manual update location for “Vendor Responded” field

---

## Tips
- Save this file in your GitHub repo for easy project tracking and onboarding.
- Update as your project progresses or as more details become available!
