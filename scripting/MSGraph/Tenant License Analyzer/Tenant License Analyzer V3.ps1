# V3.0

# BEGIN SCRIPT

Connect-MgGraph -Scopes "Directory.Read.All","User.Read.All" -ContextScope Process | Out-Null

# Initialize report file path.
$ReportPath = "C:\Temp\TenantLicenseReport.xlsx"

# Initialize exluded SKUs list.
$ExcludedSKUs = @("37c86dd4-ca27-4f07-8abc-fdf4a34d986c")

# Get all subscribed SKUs in the tenant.
$SubscribedSKUs = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/subscribedSkus"
$SubscribedSKUs.value = $SubscribedSKUs.value | Where SkuId -NotIn $ExcludedSKUs

# Initialize all known licenses as hashtable.
$LicensesHashTable = @{

"e0dfc8b9-9531-4ec8-94b4-9fec23b05fc8" = "Microsoft Teams Exploratory"
"b49494c3-64d5-42da-9e32-ca44cb37f259" = "Microsoft 365 E5 eDiscovery and Audit"
"d26c9494-887c-4de2-96be-37a71243e6f8" = "Microsoft Defender for Business Servers"
"e4654015-5daf-4a48-9b37-4f309dddd88b" = "Advanced Communications"
"d2dea78b-507c-4e56-b400-39447f4738f8" = "AI Builder Capacity add-on"
"8f0c5670-4e56-4892-b06d-91c085d7004f" = "App Connect IW"
"9706eed9-966f-4f1b-94f6-bb2b4af99a5b" = "App governance add-on to Microsoft Defender for Cloud Apps"
"0c266dff-15dd-4b49-8397-2bb16070ed52" = "Microsoft 365 Audio Conferencing"
"2b9c8e7c-319c-43a2-a2a0-48c5c6161de7" = "Microsoft Entra ID Basic"
"078d2b04-f1bd-4111-bbd4-b4b1b354cef4" = "Microsoft Entra ID P1"
"30fc3c36-5a95-4956-ba57-c09c2a600bb9" = "Microsoft Entra ID P1 for Faculty"
"de597797-22fb-4d65-a9fe-b7dbe8893914" = "Microsoft Entra ID P1_USGOV_GCCHIGH"
"84a661c4-e949-4bd2-a560-ed7766fcaf2b" = "Microsoft Entra ID P2"
"c52ea49f-fe5d-4e95-93ba-1de91d380f89" = "Azure Information Protection Plan 1"
"a0e6a48f-b056-4037-af70-b9ac53504551" = "Azure Information Protection Plan 1"
"c57afa2a-d468-46c4-9a90-f86cb1b3c54a" = "Azure Information Protection Premium P1_USGOV_GCCHIGH"
"90d8b3f8-712e-4f7b-aa1e-62e7ae6cbe96" = "Business Apps (free)"
"631d5fb1-a668-4c2a-9427-8830665a742e" = "Common Data Service for Apps File Capacity"
"e612d426-6bc3-4181-9658-91aa906b0ac0" = "Common Data Service Database Capacity"
"eddf428b-da0e-4115-accf-b29eb0b83965" = "Common Data Service Database Capacity for Government"
"448b063f-9cc6-42fc-a0e6-40e08724a395" = "Common Data Service Log Capacity"
"47794cd0-f0e5-45c5-9033-2eb6b5fc84e0" = "Communications Credits"
"8a5fbbed-8b8c-41e5-907e-c50c471340fd" = "Compliance Manager Premium Assessment Add-On"
"a9d7ef53-9bea-4a2a-9650-fa7df58fe094" = "Compliance Manager Premium Assessment Add-On for GCC"
"a9c51c15-ffad-4c66-88c0-8771455c832d" = "Defender Threat Intelligence"
"328dc228-00bc-48c6-8b09-1fbc8bc3435d" = "Dynamics 365 - Additional Database Storage (Qualified Offer)"
"9d776713-14cb-4697-a21d-9a52455c738a" = "Dynamics 365 - Additional Production Instance (Qualified Offer)"
"e06abcc2-7ec5-4a79-b08b-d9c282376f72" = "Dynamics 365 - Additional Non-Production Instance (Qualified Offer)"
"c6df1e30-1c9f-427f-907c-3d913474a1c7" = "Dynamics 365 AI for Market Insights (Preview)"
"673afb9d-d85b-40c2-914e-7bf46cd5cd75" = "Dynamics 365 Asset Management Addl Assets"
"a58f5506-b382-44d4-bfab-225b2fbf8390" = "Dynamics 365 Business Central Additional Environment Addon"
"7d0d4f9a-2686-4cb8-814c-eff3fdab6d74" = "Dynamics 365 Business Central Database Capacity"
"2880026b-2b0c-4251-8656-5d41ff11e3aa" = "Dynamics 365 Business Central Essentials"
"9a1e33ed-9697-43f3-b84c-1b0959dbb1d4" = "Dynamics 365 Business Central External Accountant"
"6a4a1628-9b9a-424d-bed5-4118f0ede3fd" = "Dynamics 365 Business Central for IWs"
"f991cecc-3f91-4cd0-a9a8-bf1c8167e029" = "Dynamics 365 Business Central Premium"
"2e3c4023-80f6-4711-aa5d-29e0ecb46835" = "Dynamics 365 Business Central Team Members"
"1508ad2d-5802-44e6-bfe8-6fb65de63d28" = "Dynamics 365 Commerce Trial"
"ea126fc5-a19e-42e2-a731-da9d437bffcf" = "Dynamics 365 Customer Engagement Plan"
"a3d0cd86-8068-4071-ad40-4dc5b5908c4b" = "Dynamics 365 Customer Insights Attach"
"94a6fbd4-6a2f-4990-b356-dc7dd8bed08a" = "Dynamics 365 Customer Service Enterprise Admin"
"0c250654-c7f7-461f-871a-7222f6592cf2" = "Dynamics 365 Customer Insights Standalone"
"036c2481-aa8a-47cd-ab43-324f0c157c2d" = "Dynamics 365 Customer Insights vTrial"
"eb18b715-ea9d-4290-9994-2ebf4b5042d2" = "Dynamics 365 for Customer Service Enterprise Attach to Qualifying Dynamics 365 Base Offer A"
"1e615a51-59db-4807-9957-aa83c3657351" = "Dynamics 365 Customer Service Enterprise Viral Trial"
"61e6bd70-fbdb-4deb-82ea-912842f39431" = "Dynamics 365 Customer Service Insights Trial"
"bc946dac-7877-4271-b2f7-99d2db13cd2c" = "Dynamics 365 Customer Voice Trial"
"1439b6e2-5d59-4873-8c59-d60e2a196e92" = "Dynamics 365 Customer Service Professional"
"359ea3e6-8130-4a57-9f8f-ad897a0342f1" = "Dynamics 365 Customer Voice"
"446a86f8-a0cb-4095-83b3-d100eb050e3d" = "Dynamics 365 Customer Voice Additional Responses"
"65f71586-ade3-4ce1-afc0-1b452eaf3782" = "Dynamics 365 Customer Voice Additional Responses"
"e2ae107b-a571-426f-9367-6d4c8f1390ba" = "Dynamics 365 Customer Voice USL"
"a4bfb28e-becc-41b0-a454-ac680dc258d3" = "Dynamics 365 Enterprise Edition - Additional Portal (Qualified Offer)"
"977464c4-bfaf-4b67-b761-a9bb735a2196" = "Dynamics 365 Field Service, Enterprise Edition - Resource Scheduling Optimization"
"29fcd665-d8d1-4f34-8eed-3811e3fca7b3" = "Dynamics 365 Field Service Viral Trial"
"55c9eb4e-c746-45b4-b255-9ab6b19d5c62" = "Dynamics 365 Finance"
"d39fb075-21ae-42d0-af80-22a2599749e0" = "Dynamics 365 for Case Management Enterprise Edition"
"7d7af6c2-0be6-46df-84d1-c181b0272909" = "Dynamics 365 for Customer Service Chat"
"749742bf-0d37-4158-a120-33567104deeb" = "Dynamics 365 for Customer Service Enterprise Edition"
"a36cdaa2-a806-4b6e-9ae0-28dbd993c20e" = "Dynamics 365 for Field Service Attach to Qualifying Dynamics 365 Base Offer"
"c7d15985-e746-4f01-b113-20b575898250" = "Dynamics 365 for Field Service Enterprise Edition"
"cc13a803-544e-4464-b4e4-6d6169a138fa" = "Dynamics 365 for Financials Business Edition"
"de176c31-616d-4eae-829a-718918d7ec23" = "Dynamics 365 Hybrid Connector"
"99c5688b-6c75-4496-876f-07f0fbd69add" = "Dynamics 365 for Marketing Additional Application"
"23053933-0fda-431f-9a5b-a00fd78444c1" = "Dynamics 365 for Marketing Addnl Contacts Tier 3"
"d8eec316-778c-4f14-a7d1-a0aca433b4e7" = "Dynamics 365 for Marketing Addnl Contacts Tier 5"
"c393e9bd-2335-4b46-8b88-9e2a86a85ec1" = "Dynamics 365 for Marketing Additional Non-Prod Application"
"85430fb9-02e8-48be-9d7e-328beb41fa29" = "Dynamics 365 for Marketing Attach"
"4b32a493-9a67-4649-8eb9-9fc5a5f75c12" = "Dynamics 365 for Marketing USL"
"8edc2cf8-6438-4fa9-b6e3-aa1660c640cc" = "Dynamics 365 for Sales and Customer Service Enterprise Edition"
"1e1a282c-9c54-43a2-9310-98ef728faace" = "Dynamics 365 for Sales Enterprise Edition"
"494721b8-1f30-4315-aba6-70ca169358d9" = "Dynamics 365 Sales, Field Service and Customer Service Partner Sandbox"
"2edaa1dc-966d-4475-93d6-8ee8dfd96877" = "Dynamics 365 Sales Premium"
"238e2f8d-e429-4035-94db-6926be4ffe7b" = "Dynamics 365 for Marketing Business Edition"
"7ed4877c-0863-4f69-9187-245487128d4f" = "Dynamics 365 Regulatory Service - Enterprise Edition Trial"
"6ec92958-3cc1-49db-95bd-bc6b3798df71" = "Dynamics 365 Sales Premium Viral Trial"
"be9f9771-1c64-4618-9907-244325141096" = "Dynamics 365 For Sales Professional"
"9c7bff7a-3715-4da7-88d3-07f57f8d0fb6" = "Dynamics 365 For Sales Professional Trial"
"245e6bf9-411e-481e-8611-5c08595e2988" = "Dynamics 365 Sales Professional Attach to Qualifying Dynamics 365 Base Offer"
"f2e48cb3-9da0-42cd-8464-4a54ce198ad0" = "Dynamics 365 for Supply Chain Management"
"3a256e9a-15b6-4092-b0dc-82993f4debc6" = "Dynamics 365 for Talent"
"e561871f-74fa-4f02-abee-5b0ef54dd36d" = "Dynamics 365 Talent: Attract"
"8e7a3d30-d97d-43ab-837c-d7701cef83dc" = "Dynamics 365 for Team Members Enterprise Edition"
"0a389a77-9850-4dc4-b600-bc66fdfefc60" = "Dynamics 365 Guides"
"3bbd44ed-8a70-4c07-9088-6232ddbd5ddd" = "Dynamics 365 Operations - Device"
"e485d696-4c87-4aac-bf4a-91b2fb6f0fa7" = "Dynamics 365 Operations - Sandbox Tier 2:Standard Acceptance Testing"
"f7ad4bca-7221-452c-bdb6-3e6089f25e06" = "Dynamics 365 Operations - Sandbox Tier 4:Standard Performance Testing"
"338148b6-1b11-4102-afb9-f92b6cdc0f8d" = "Dynamics 365 P1 Tria for Information Workers"
"7a551360-26c4-4f61-84e6-ef715673e083" = "Dynamics 365 Remote Assist"
"e48328a2-8e98-4484-a70f-a99f8ac9ec89" = "Dynamics 365 Remote Assist HoloLens"
"5b22585d-1b71-4c6b-b6ec-160b1a9c2323" = "Dynamics 365 Sales Enterprise Attach to Qualifying Dynamics 365 Base Offer"
"b56e7ccc-d5c7-421f-a23b-5c18bdbad7c0" = "Dynamics 365 Talent: Onboard"
"7ac9fe77-66b7-4e5e-9e46-10eed1cff547" = "Dynamics 365 Team Members"
"ccba3cfe-71ef-423a-bd87-b6df3dce59a9" = "Dynamics 365 UNF OPS Plan ENT Edition"
"aedfac18-56b8-45e3-969b-53edb4ba4952" = "Enterprise Mobility + Security A3 for Faculty"
"efccb6f7-5641-4e0e-bd10-b4976e1bf68e" = "Enterprise Mobility + Security E3"
"b05e124f-c7cc-45a0-a6aa-8cf78c946968" = "Enterprise Mobility + Security E5"
"a461b89c-10e3-471c-82b8-aae4d820fccb" = "Enterprise Mobility + Security E5_USGOV_GCCHIGH"
"c793db86-5237-494e-9b11-dcd4877c2c8c" = "Enterprise Mobility + Security G3 GCC"
"8a180c2b-f4cf-4d44-897c-3d32acc4a60b" = "Enterprise Mobility + Security G5 GCC"
"e8ecdf70-47a8-4d39-9d15-093624b7f640" = "Exchange Enterprise CAL Services (EOP DLP)"
"4b9405b0-7788-4568-add1-99614e613b69" = "Exchange Online (Plan 1)"
"aa0f9eb7-eff2-4943-8424-226fb137fcad" = "Exchange Online (Plan 1) for Alumni with Yammer"
"ad2fe44a-915d-4e2b-ade1-6766d50a9d9c" = "Exchange Online (Plan 1) for Students"
"f37d5ebf-4bf1-4aa2-8fa3-50c51059e983" = "Exchange Online (Plan 1) for GCC"
"19ec0d23-8335-4cbd-94ac-6050e30712fa" = "Exchange Online (Plan 2)"
"0b7b15a8-7fd2-4964-bb96-5a566d4e3c15" = "Exchange Online (Plan 2) for Faculty"
"ee02fd1b-340e-4a4b-b355-4a514e4c8943" = "Exchange Online Archiving for Exchange Online"
"90b5e015-709a-4b8b-b08e-3200f994494c" = "Exchange Online Archiving for Exchange Server"
"7fc0182e-d107-4556-8329-7caaa511197b" = "Exchange Online Essentials (ExO P1 Based)"
"e8f81a67-bd96-4074-b108-cf193eb9433b" = "Exchange Online Essentials"
"80b2d799-d2ba-4d2a-8842-fb0d0f3a4b82" = "Exchange Online Kiosk"
"cb0a98a8-11bc-494c-83d9-c1b1ac65327e" = "Exchange Online POP"
"45a2423b-e884-448d-a831-d9e139c52d2f" = "Exchange Online Protection"
"061f9ace-7d42-4136-88ac-31dc755f143f" = "Intune"
"d9d89b70-a645-4c24-b041-8d3cb1884ec7" = "Intune for Education"
"fcecd1f9-a91e-488d-a918-a96cdb6ce2b0" = "Microsoft Dynamics AX7 User Trial"
"cb2020b1-d8f6-41c0-9acd-8ff3d6d7831b" = "Microsoft Azure Multi-Factor Authentication"
"3dd6cf57-d688-4eed-ba52-9e40b5468c3e" = "Microsoft Defender for Office 365 (Plan 2)"
"b17653a4-2443-4e8c-a550-18249dda78bb" = "Microsoft 365 A1"
"4b590615-0888-425a-a965-b3bf7789848d" = "Microsoft 365 A3 for Faculty"
"7cfd9a2b-e110-4c39-bf20-c6a3f36a3121" = "Microsoft 365 A3 for Students"
"18250162-5d87-4436-a834-d795c15c80f3" = "Microsoft 365 A3 for students use benefit"
"32a0e471-8a27-4167-b24f-941559912425" = "Microsoft 365 A3 Suite features for faculty"
"1aa94593-ca12-4254-a738-81a5972958e8" = "Microsoft 365 A3 - Unattended License for students use benefit"
"e97c048c-37a4-45fb-ab50-922fbf07a370" = "Microsoft 365 A5 for Faculty"
"46c119d4-0379-4a9d-85e4-97c66d3f909e" = "Microsoft 365 A5 for Students"
"31d57bc7-3a05-4867-ab53-97a17835a411" = "Microsoft 365 A5 for students use benefit"
"9b8fe788-6174-4c4e-983b-3330c93ec278" = "Microsoft 365 A5 Suite features for faculty"
"81441ae1-0b31-4185-a6c0-32b6b84d419f" = "Microsoft 365 A5 without Audio Conferencing for students use benefit"
"cdd28e44-67e3-425e-be4c-737fab2899d3" = "Microsoft 365 Apps for Business"
"b214fe43-f5a3-4703-beeb-fa97188220fc" = "Microsoft 365 Apps for Business"
"c2273bd0-dff7-4215-9ef5-2c7bcfb06425" = "Microsoft 365 Apps for Enterprise"
"ea4c5ec8-50e3-4193-89b9-50da5bd4cdc7" = "Microsoft 365 Apps for enterprise (device)"
"c32f9321-a627-406d-a114-1f9c81aaafac" = "Microsoft 365 Apps for Students"
"12b8c807-2e20-48fc-b453-542b6ee9d171" = "Microsoft 365 Apps for Faculty"
"2d3091c7-0712-488b-b3d8-6b97bde6a1f5" = "Microsoft 365 Audio Conferencing for GCC"
"4dee1f32-0808-4fd2-a2ed-fdd575e3a45f" = "Microsoft 365 Audio Conferencing_USGOV_GCCHIGH"
"170ba00c-38b2-468c-a756-24c05037160a" = "Microsoft 365 Audio Conferencing - GCCHigh Tenant (AR)_USGOV_GCCHIGH"
"df9561a4-4969-4e6a-8e73-c601b68ec077" = "Microsoft 365 Audio Conferencing Pay-Per-Minute - EA"
"3b555118-da6a-4418-894f-7df1e2096870" = "Microsoft 365 Business Basic"
"dab7782a-93b1-4074-8bb1-0e61318bea0b" = "Microsoft 365 Business Basic"
"f245ecc8-75af-4f8e-b61f-27d8114de5f3" = "Microsoft 365 Business Standard"
"ac5cef5d-921b-4f97-9ef3-c99076e5470f" = "Microsoft 365 Business Standard - Prepaid Legacy"
"cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46" = "Microsoft 365 Business Premium"
"11dee6af-eca8-419f-8061-6864517c1875" = "Microsoft 365 Domestic Calling Plan (120 Minutes)"
"923f58ab-fca1-46a1-92f9-89fda21238a8" = "Microsoft 365 Domestic Calling Plan for GCC"
"05e9a617-0261-4cee-bb44-138d3ef5d965" = "Microsoft 365 E3"
"f5b15d67-b99e-406b-90f1-308452f94de6" = "Microsoft 365 E3 Extra Features"
"c2ac2ee4-9bb1-47e4-8541-d689c7e83371" = "Microsoft 365 E3 - Unattended License"
"0c21030a-7e60-4ec7-9a0f-0042e0e0211a" = "Microsoft 365 E3 (500 seats min)_HUB"
"d61d61cc-f992-433f-a577-5bd016037eeb" = "Microsoft 365 E3_USGOV_DOD"
"ca9d1dd9-dfe9-4fef-b97c-9bc1ea3c3658" = "Microsoft 365 E3_USGOV_GCCHIGH"
"06ebc4ee-1bb5-47dd-8120-11324bc54e06" = "Microsoft 365 E5"
"db684ac5-c0e7-4f92-8284-ef9ebde75d33" = "Microsoft 365 E5 (500 seats min)_HUB"
"c42b9cae-ea4f-4ab7-9717-81576235ccac" = "Microsoft 365 E5 Developer (without Windows and Audio Conferencing)"
"184efa21-98c3-4e5d-95ab-d07053a96e67" = "Microsoft 365 E5 Compliance"
"26124093-3d78-432b-b5dc-48bf992543d5" = "Microsoft 365 E5 Security"
"44ac31e7-2999-4304-ad94-c948886741d4" = "Microsoft 365 E5 Security for EMS E5"
"a91fc4e0-65e5-4266-aa76-4037509c1626" = "Microsoft 365 E5 with Calling Minutes"
"cd2925a3-5076-4233-8931-638a8c94f773" = "Microsoft 365 E5 without Audio Conferencing"
"2113661c-6509-4034-98bb-9c47bd28d63c" = "Microsoft 365 E5 without Audio Conferencing (500 seats min)_HUB"
"4eb45c5b-0d19-4e33-b87c-adfc25268f20" = "Microsoft 365 E5_USGOV_GCCHIGH"
"44575883-256e-4a79-9da4-ebe9acabe2b2" = "Microsoft 365 F1"
"66b55226-6b4f-492c-910c-a3b7a3c9d993" = "Microsoft 365 F3"
"2a914830-d700-444a-b73c-e3f31980d833" = "Microsoft 365 F3 GCC"
"91de26be-adfa-4a3d-989e-9131cc23dda7" = "Microsoft 365 F5 Compliance Add-on"
"9cfd6bc3-84cd-4274-8a21-8c7c41d6c350" = "Microsoft 365 F5 Compliance Add-on AR (DOD)_USGOV_DOD"
"9f436c0e-fb32-424b-90be-6a9f2919d506" = "Microsoft 365 F5 Compliance Add-on AR_USGOV_GCCHIGH"
"3f17cf90-67a2-4fdb-8587-37c1539507e1" = "Microsoft 365 F5 Compliance Add-on GCC"
"67ffe999-d9ca-49e1-9d2c-03fb28aa7a48" = "Microsoft 365 F5 Security Add-on"
"32b47245-eb31-44fc-b945-a8b1576c439f" = "Microsoft 365 F5 Security + Compliance Add-on"
"e2be619b-b125-455f-8660-fb503e431a5d" = "Microsoft 365 GCC G5"
"99cc8282-2f74-4954-83b7-c6a9a1999067" = "Microsoft 365 E5 Suite features"
"50f60901-3181-4b75-8a2c-4c8e4c1d5a72" = "Microsoft 365 F1"
"e823ca47-49c4-46b3-b38d-ca11d5abe3d2" = "Microsoft 365 G3 GCC"
"9c0587f3-8665-4252-a8ad-b7a5ade57312" = "Microsoft 365 Lighthouse"
"2347355b-4e81-41a4-9c22-55057a399791" = "Microsoft 365 Security and Compliance for Firstline Workers"
"726a0894-2c77-4d65-99da-9775ef05aad1" = "Microsoft Business Center"
"df845ce7-05f9-4894-b5f2-11bbfbcfd2b6" = "Microsoft Cloud App Security"
"556640c0-53ea-4773-907d-29c55332983f" = "Microsoft Cloud for Sustainability vTrial"
"111046dd-295b-4d6d-9724-d52ac90bd1f2" = "Microsoft Defender for Endpoint"
"16a55f2f-ff35-4cd5-9146-fb784e3761a5" = "Microsoft Defender for Endpoint P1"
"bba890d4-7881-4584-8102-0c3fdfb739a7" = "Microsoft Defender for Endpoint P1 for EDU"
"b126b073-72db-4a9d-87a4-b17afe41d4ab" = "Microsoft Defender for Endpoint P2_XPLAT"
"509e8ab6-0274-4cda-bcbd-bd164fd562c4" = "Microsoft Defender for Endpoint Server"
"906af65a-2970-46d5-9b58-4e9aa50f0657" = "Microsoft Dynamics CRM Online Basic"
"98defdf7-f6c1-44f5-a1f6-943b6764e7a5" = "Microsoft Defender for Identity"
"26ad4b5c-b686-462e-84b9-d7c22b46837f" = "Microsoft Defender for Office 365 (Plan 1) Faculty"
"d0d1ca43-b81a-4f51-81e5-a5b1ad7bb005" = "Microsoft Defender for Office 365 (Plan 1) GCC"
"550f19ba-f323-4a7d-a8d2-8971b0d9ea85" = "Microsoft Defender for Office 365 (Plan 1)_USGOV_GCCHIGH"
"56a59ffb-9df1-421b-9e61-8b568583474d" = "Microsoft Defender for Office 365 (Plan 2) GCC"
"1925967e-8013-495f-9644-c99f8b463748" = "Microsoft Defender Vulnerability Management"
"ad7a56e0-6903-4d13-94f3-5ad491e78960" = "Microsoft Defender Vulnerability Management Add-on"
"d17b27af-3f49-4822-99f9-56a661538792" = "Microsoft Dynamics CRM Online"
"a403ebcc-fae0-4ca2-8c8c-7a907fd6c235" = "Microsoft Fabric (Free)"
"ade29b5f-397e-4eb9-a287-0344bd46c68d" = "Microsoft Fabric (Free) for faculty"
"bdcaf6aa-04c1-4b8f-b64e-6e3bd505ac64" = "Microsoft Fabric (Free) for student"
"ba9a34de-4489-469d-879c-0f0f145321cd" = "Microsoft Imagine Academy"
"2b317a4a-77a6-4188-9437-b68a77b4e2c6" = "Microsoft Intune Device"
"2c21e77a-e0d6-4570-b38a-7ff2dc17d2ca" = "Microsoft Intune Device for Government"
"b4288abe-01be-47d9-ad20-311d6e83fc24" = "Microsoft Intune Plan 1 A VL_USGOV_GCCHIGH"
"5b631642-bd26-49fe-bd20-1daaa972ef80" = "Microsoft Power Apps for Developer"
"dcb1a3ae-b33f-4487-846a-a640262fadf4" = "Microsoft Power Apps Plan 2 Trial"
"f30db892-07e9-47e9-837c-80727f46fd3d" = "Microsoft Power Automate Free"
"4755df59-3f73-41ab-a249-596ad72b5504" = "Microsoft Power Automate Plan 2"
"e6025b08-2fa5-4313-bd0a-7e5ffca32958" = "Microsoft Intune SMB"
"a929cd4d-8672-47c9-8664-159c1f322ba8" = "Microsoft Intune Suite"
"ddfae3e3-fcb2-4174-8ebd-3023cb213c8b" = "Microsoft Power Apps Plan 2 (Qualified Offer)"
"4f05b1a3-a978-462c-b93f-781c6bee998f" = "Microsoft Relationship Sales solution"
"1f2f344a-700d-42c9-9427-5cea1d5d7ba6" = "Microsoft Stream"
"ec156933-b85b-4c50-84ec-c9e5603709ef" = "Microsoft Stream Plan 2"
"9bd7c846-9556-4453-a542-191d527209e8" = "Microsoft Stream Storage Add-On (500 GB)"
"1c27243e-fb4d-42b1-ae8c-fe25c9616588" = "Microsoft Teams Audio Conferencing with dial-out to USA/CAN"
"16ddbbfc-09ea-4de2-b1d7-312db6112d70" = "Microsoft Teams (Free)"
"fde42873-30b6-436b-b361-21af5a6b84ae" = "Microsoft Teams Essentials"
"3ab6abff-666f-4424-bfb7-f0bc274ec7bc" = "Microsoft Teams Essentials (AAD Identity)"
"710779e8-3d4a-4c88-adb9-386c958d1fdf" = "Microsoft Teams Exploratory"
"e43b5b99-8dfb-405f-9987-dc307f34bcbd" = "Microsoft Teams Phone Standard"
"d01d9287-694b-44f3-bcc5-ada78c8d953e" = "Microsoft Teams Phone Standard for DOD"
"d979703c-028d-4de5-acbf-7955566b69b9" = "Microsoft Teams Phone Standard for Faculty"
"a460366a-ade7-4791-b581-9fbff1bdaa85" = "Microsoft Teams Phone Standard for GCC"
"7035277a-5e49-4abc-a24f-0ec49c501bb5" = "Microsoft Teams Phone Standard for GCCHIGH"
"aa6791d3-bb09-4bc2-afed-c30c3fe26032" = "Microsoft Teams Phone Standard for Small and Medium Business"
"1f338bbc-767e-4a1e-a2d4-b73207cc5b93" = "Microsoft Teams Phone Standard for Students"
"ffaf2d68-1c95-4eb3-9ddd-59b81fba0f61" = "Microsoft Teams Phone Standard for TELSTRA"
"b0e7de67-e503-4934-b729-53d595ba5cd1" = "Microsoft Teams Phone Standard_USGOV_DOD"
"985fcb26-7b94-475b-b512-89356697be71" = "Microsoft Teams Phone Standard_USGOV_GCCHIGH"
"440eaaa8-b3e0-484b-a8be-62870b9ba70a" = "Microsoft Teams Phone Resource Account"
"2cf22bcb-0c9e-4bc6-8daf-7e7654c0f285" = "Microsoft Teams Phone Resource Account for GCC"
"e3f0522e-ebb7-4561-9f90-b44516d65b77" = "Microsoft Teams Phone Resource Account_USGOV_GCCHIGH"
"36a0f3b3-adb5-49ea-bf66-762134cf063a" = "Microsoft Teams Premium Introductory Pricing"
"6af4b3d6-14bb-4a2a-960c-6c902aad34f3" = "Microsoft Teams Rooms Basic"
"a4e376bd-c61e-4618-9901-3fc0cb1b88bb" = "Microsoft Teams Rooms Basic for EDU"
"50509a35-f0bd-4c5e-89ac-22f0e16a00f8" = "Microsoft Teams Rooms Basic without Audio Conferencing"
"4cde982a-ede4-4409-9ae6-b003453c8ea6" = "Microsoft Teams Rooms Pro"
"c25e2b36-e161-4946-bef2-69239729f690" = "Microsoft Teams Rooms Pro for EDU"
"21943e3a-2429-4f83-84c1-02735cd49e78" = "Microsoft Teams Rooms Pro without Audio Conferencing"
"295a8eb0-f78d-45c7-8b5b-1eed5ed02dff" = "Microsoft Teams Shared Devices"
"b1511558-69bd-4e1b-8270-59ca96dba0f3" = "Microsoft Teams Shared Devices for GCC"
"6070a4c8-34c6-4937-8dfb-39bbc6397a60" = "Microsoft Teams Rooms Standard"
"61bec411-e46a-4dab-8f46-8b58ec845ffe" = "Microsoft Teams Rooms Standard without Audio Conferencing"
"74fbf1bb-47c6-4796-9623-77dc7371723b" = "Microsoft Teams Trial"
"9fa2f157-c8e4-4351-a3f2-ffa506da1406" = "Microsoft Threat Experts - Experts on Demand"
"ba929637-f158-4dee-927c-eb7cdefcd955" = "Microsoft Viva Goals"
"3dc7332d-f0fa-40a3-81d3-dd6b84469b78" = "Microsoft Viva Glint"
"61902246-d7cb-453e-85cd-53ee28eec138" = "Microsoft Viva Suite"
"533b8f26-f74b-4e9c-9c59-50fc4b393b63" = "Minecraft Education Student"
"984df360-9a74-4647-8cf8-696749f6247a" = "Minecraft Education Faculty"
"84951599-62b7-46f3-9c9d-30551b2ad607" = "Multi-Geo Capabilities in Office 365"
"aa2695c9-8d59-4800-9dc8-12e01f1735af" = "Nonprofit Portal"
"94763226-9b3c-4e75-a931-5c89701abe66" = "Office 365 A1 for faculty"
"78e66a63-337a-4a9a-8959-41c6654dfb56" = "Office 365 A1 Plus for faculty"
"314c4481-f395-4525-be8b-2ec4bb1e9d91" = "Office 365 A1 for students"
"e82ae690-a2d5-4d76-8d30-7c6e01e6022e" = "Office 365 A1 Plus for students"
"e578b273-6db4-4691-bba0-8d691f4da603" = "Office 365 A3 for faculty"
"98b6e773-24d4-4c0d-a968-6e787a1f8204" = "Office 365 A3 for students"
"a4585165-0533-458a-97e3-c400570268c4" = "Office 365 A5 for faculty"
"ee656612-49fa-43e5-b67e-cb1fdf7699df" = "Office 365 A5 for students"
"1b1b1f7a-8355-43b6-829f-336cfccb744c" = "Office 365 Advanced Compliance"
"1a585bba-1ce3-416e-b1d6-9c482b52fcf6" = "Office 365 Advanced Compliance for GCC"
"4ef96642-f096-40de-a3e9-d83fb2f90211" = "Microsoft Defender for Office 365 (Plan 1)"
"e5788282-6381-469f-84f0-3d7d4021d34d" = "Office 365 Extra File Storage for GCC"
"29a2f828-8f39-4837-b8ff-c957e86abe3c" = "Microsoft Teams Commercial Cloud"
"84d5f90f-cd0d-4864-b90b-1c7ba63b4808" = "Office 365 Cloud App Security"
"99049c9c-6011-4908-bf17-15f496e6519d" = "Office 365 Extra File Storage"
"18181a46-0d4e-45cd-891e-60aabd171b4e" = "Office 365 E1"
"6634e0ce-1a9f-428c-a498-f84ec7b8aa2e" = "Office 365 E2"
"6fd2c87f-b296-42f0-b197-1e91e994b900" = "Office 365 E3"
"189a915c-fe4f-4ffa-bde4-85b9628d07a0" = "Office 365 E3 Developer"
"b107e5a3-3e60-4c0d-a184-a7e4395eb44c" = "Office 365 E3_USGOV_DOD"
"aea38a85-9bd5-4981-aa00-616b411205bf" = "Office 365 E3_USGOV_GCCHIGH"
"1392051d-0cb9-4b7a-88d5-621fee5e8711" = "Office 365 E4"
"c7df2760-2c81-4ef7-b578-5b5392b571df" = "Office 365 E5"
"26d45bd9-adf1-46cd-a9e1-51e9a5524128" = "Office 365 E5 Without Audio Conferencing"
"4b585984-651b-448a-9e53-3b10f069cf7f" = "Office 365 F3"
"74039b88-bd62-4b5c-9d9c-7a92bbc0bfdf" = "Office 365 F3_USGOV_GCCHIGH"
"3f4babde-90ec-47c6-995d-d223749065d1" = "Office 365 G1 GCC"
"535a3a29-c5f0-42fe-8215-d3b9e1f38c4a" = "Office 365 G3 GCC"
"8900a2c0-edba-4079-bdf3-b276e293b6a8" = "Office 365 G5 GCC"
"04a7fb0d-32e0-4241-b4f5-3f7618cd1162" = "Office 365 Midsize Business"
"bd09678e-b83c-4d3f-aaba-3dad4abd128b" = "Office 365 Small Business"
"fc14ec4a-4169-49a4-a51e-2c852931814b" = "Office 365 Small Business Premium"
"e6778190-713e-4e4f-9119-8b8238de25df" = "OneDrive for Business (Plan 1)"
"ed01faf2-1d88-4947-ae91-45ca18703a96" = "OneDrive for Business (Plan 2)"
"87bbbc60-4754-4998-8c88-227dca264858" = "Power Apps and Logic Flows"
"bf666882-9c9b-4b2e-aa2f-4789b0a52ba2" = "PowerApps per app baseline access"
"a8ad7d2b-b8cf-49d6-b25a-69094a0be206" = "Power Apps per app plan"
"b4d7b828-e8dc-4518-91f9-e123ae48440d" = "Power Apps per app plan (1 app or portal)"
"b30411f5-fea1-4a59-9ad9-3db7c7ead579" = "Power Apps per user plan"
"8e4c6baa-f2ff-4884-9c38-93785d0d7ba1" = "Power Apps per user plan for Government"
"eca22b68-b31f-4e9c-a20c-4d40287bc5dd" = "PowerApps Plan 1 for Government"
"57f3babd-73ce-40de-bcb2-dadbfbfff9f7" = "Power Apps Portals login capacity add-on Tier 2 (10 unit min)"
"26c903d5-d385-4cb1-b650-8d81a643b3c4" = "Power Apps Portals login capacity add-on Tier 2 (10 unit min) for Government"
"927d8402-8d3b-40e8-b779-34e859f7b497" = "Power Apps Portals login capacity add-on Tier 3 (50 unit min)"
"a0de5e3a-2500-4a19-b8f4-ec1c64692d22" = "Power Apps Portals page view capacity add-on"
"15a64d3e-5b99-4c4b-ae8f-aa6da264bfe7" = "Power Apps Portals page view capacity add-on for Government"
"b3a42176-0a8c-4c3f-ba4e-f2b37fe5be6b" = "Power Automate per flow plan"
"4a51bf65-409c-4a91-b845-1121b571cc9d" = "Power Automate per user plan"
"d80a4c5d-8f05-4b64-9926-6574b9e6aee4" = "Power Automate per user plan dept"
"c8803586-c136-479a-8ff3-f5f32d23a68e" = "Power Automate per user plan for Government"
"eda1941c-3c4f-4995-b5eb-e85a42175ab9" = "Power Automate per user with attended RPA plan"
"3539d28c-6e35-4a30-b3a9-cd43d5d3e0e2" = "Power Automate unattended RPA add-on"
"e2767865-c3c9-4f09-9f99-6eee6eef861a" = "Power BI"
"45bc2c81-6072-436a-9b0b-3b12eefbc402" = "Power BI for Office 365 Add-On"
"7b26f5ab-a763-4c00-a1ac-f6c4b5506945" = "Power BI Premium P1"
"c1d032e0-5619-4761-9b5c-75b6831e1711" = "Power BI Premium Per User"
"de376a03-6e5b-42ec-855f-093fb50b8ca5" = "Power BI Premium Per User Add-On"
"f168a3fb-7bcf-4a27-98c3-c235ea4b78b4" = "Power BI Premium Per User Dept"
"060d8061-f606-4e69-a4e7-e8fff75ea1f5" = "Power BI Premium Per User for Faculty"
"f8a1db68-be16-40ed-86d5-cb42ce701560" = "Power BI Pro"
"420af87e-8177-4146-a780-3786adaffbca" = "Power BI Pro CE"
"3a6a908c-09c5-406a-8170-8ebb63c42882" = "Power BI Pro Dept"
"de5f128b-46d7-4cfc-b915-a89ba060ea56" = "Power BI Pro for Faculty"
"f0612879-44ea-47fb-baf0-3d76d9235576" = "Power BI Pro for GCC"
"3f9f06f5-3c31-472c-985f-62d9c10ec167" = "Power Pages vTrial for Makers"
"e4e55366-9635-46f4-a907-fc8c3b5ec81f" = "Power Virtual Agent"
"4b74a65c-8b4a-4fc8-9f6b-5177ed11ddfa" = "Power Virtual Agent User License"
"606b54a9-78d8-4298-ad8b-df6ef4481c80" = "Power Virtual Agents Viral Trial"
"e42bc969-759a-4820-9283-6b73085b68e6" = "Privacy Management   risk"
"dcdbaae7-d8c9-40cb-8bb1-62737b9e5a86" = "Privacy Management - risk for EDU"
"046f7d3b-9595-4685-a2e8-a2832d2b26aa" = "Privacy Management - risk GCC"
"83b30692-0d09-435c-a455-2ab220d504b9" = "Privacy Management - risk_USGOV_DOD"
"787d7e75-29ca-4b90-a3a9-0b780b35367c" = "Privacy Management - risk_USGOV_GCCHIGH"
"d9020d1c-94ef-495a-b6de-818cbbcaa3b8" = "Privacy Management - subject rights request (1)"
"475e3e81-3c75-4e07-95b6-2fed374536c8" = "Privacy Management - subject rights request (1) for EDU"
"017fb6f8-00dd-4025-be2b-4eff067cae72" = "Privacy Management - subject rights request (1) GCC"
"d3c841f3-ea93-4da2-8040-6f2348d20954" = "Privacy Management - subject rights request (1) USGOV_DOD"
"706d2425-6170-4818-ba08-2ad8f1d2d078" = "Privacy Management - subject rights request (1) USGOV_GCCHIGH"
"78ea43ac-9e5d-474f-8537-4abb82dafe27" = "Privacy Management - subject rights request (10)"
"e001d9f1-5047-4ebf-8927-148530491f83" = "Privacy Management - subject rights request (10) for EDU"
"a056b037-1fa0-4133-a583-d05cff47d551" = "Privacy Management - subject rights request (10) GCC"
"ab28dfa1-853a-4f54-9315-f5146975ac9a" = "Privacy Management - subject rights request (10) USGOV_DOD"
"f6aa3b3d-62f4-4c1d-a44f-0550f40f729c" = "Privacy Management - subject rights request (10) USGOV_GCCHIGH"
"c416b349-a83c-48cb-9529-c420841dedd6" = "Privacy Management - subject rights request (50)"
"f6c82f13-9554-4da1-bed3-c024cc906e02" = "Privacy Management - subject rights request (50)"
"ed45d397-7d61-4110-acc0-95674917bb14" = "Privacy Management - subject rights request (50) for EDU"
"cf4c6c3b-f863-4940-97e8-1d25e912f4c4" = "Privacy Management - subject rights request (100)"
"9b85b4f0-92d9-4c3d-b230-041520cb1046" = "Privacy Management - subject rights request (100) for EDU"
"91bbc479-4c2c-4210-9c88-e5b468c35b83" = "Privacy Management - subject rights request (100) GCC"
"ba6e69d5-ba2e-47a7-b081-66c1b8e7e7d4" = "Privacy Management - subject rights request (100) USGOV_DOD"
"cee36ce4-cc31-481f-8cab-02765d3e441f" = "Privacy Management - subject rights request (100) USGOV_GCCHIGH"
"a10d5e58-74da-4312-95c8-76be4e5b75a0" = "Project for Office 365"
"776df282-9fc0-4862-99e2-70e561b9909e" = "Project Online Essentials"
"e433b246-63e7-4d0b-9efa-7940fa3264d6" = "Project Online Essentials for Faculty"
"ca1a159a-f09e-42b8-bb82-cb6420f54c8e" = "Project Online Essentials for GCC"
"09015f9f-377f-4538-bbb5-f75ceb09358a" = "Project Online Premium"
"2db84718-652c-47a7-860c-f10d8abbdae3" = "Project Online Premium Without Project Client"
"f82a60b8-1ee3-4cfb-a4fe-1c6a53c2656c" = "Project Online With Project for Office 365"
"beb6439c-caad-48d3-bf46-0c82871e12be" = "Project Plan 1"
"84cd610f-a3f8-4beb-84ab-d9d2c902c6c9" = "Project Plan 1 (for Department)"
"53818b1b-4a27-454b-8896-0dba576410e6" = "Project Plan 3"
"46102f44-d912-47e7-b0ca-1bd7b70ada3b" = "Project Plan 3 (for Department)"
"46974aed-363e-423c-9e6a-951037cec495" = "Project Plan 3 for Faculty"
"074c6829-b3a0-430a-ba3d-aca365e57065" = "Project Plan 3 for GCC"
"64758d81-92b7-4855-bcac-06617becb3e8" = "Project Plan 3_USGOV_GCCHIGH"
"f2230877-72be-4fec-b1ba-7156d6f75bd6" = "Project Plan 5 for GCC"
"b732e2a7-5694-4dff-a0f2-9d9204c794ac" = "Project Plan 5 without Project Client for Faculty"
"8c4ce438-32a7-4ac5-91a6-e22ae08d9c8b" = "Rights Management Adhoc"
"093e8d14-a334-43d9-93e3-30589a8b47d0" = "Rights Management Service Basic Content Protection"
"08e18479-4483-4f70-8f17-6f92156d8ea9" = "Sensor Data Intelligence Additional Machines Add-in for Dynamics 365 Supply Chain Management"
"9ea4bdef-a20b-4668-b4a7-73e1f7696e0a" = "Sensor Data Intelligence Scenario Add-in for Dynamics 365 Supply Chain Management"
"1fc08a02-8b3d-43b9-831e-f76859e04e1a" = "SharePoint Online (Plan 1)"
"a9732ec9-17d9-494c-a51c-d6b45b384dcb" = "SharePoint Online (Plan 2)"
"f61d4aba-134f-44e9-a2a0-f81a5adb26e4" = "SharePoint Syntex"
"b8b749f8-a4ef-4887-9539-c95b1eaa5db7" = "Skype for Business Online (Plan 1)"
"d42c793f-6c78-4f43-92ca-e8f6a02b035f" = "Skype for Business Online (Plan 2)"
"d3b4fe1f-9992-4930-8acb-ca6ec609365e" = "Skype for Business PSTN Domestic and International Calling"
"0dab259f-bf13-4952-b7f8-7db8f131b28d" = "Skype for Business PSTN Domestic Calling"
"54a152dc-90de-4996-93d2-bc47e670fc06" = "Skype for Business PSTN Domestic Calling (120 Minutes)"
"06b48c5f-01d9-4b18-9015-03b52040f51a" = "Skype for Business PSTN Usage Calling Plan"
"ae2343d1-0999-43f6-ae18-d816516f6e78" = "Teams Phone with Calling Plan"
"4fb214cb-a430-4a91-9c91-4976763aa78f" = "Teams Rooms Premium"
"de3312e1-c7b0-46e6-a7c3-a515ff90bc86" = "TELSTRA Calling for O365"
"9f3d9c1d-25a5-4aaa-8e59-23a1e6450a67" = "Universal Print"
"ca7f3140-d88c-455b-9a1c-7f0679e31a76" = "Visio Plan 1"
"38b434d2-a15e-4cde-9a98-e737c75623e1" = "Visio Plan 2"
"80e52531-ad7f-44ea-abc3-28e389462f1b" = "Visio Plan 2_USGOV_GCCHIGH"
"4b244418-9658-4451-a2b8-b5e2b364e9bd" = "Visio Online Plan 1"
"c5928f49-12ba-48f7-ada3-0d743a3601d5" = "Visio Online Plan 2"
"4ae99959-6b0f-43b0-b1ce-68146001bdba" = "Visio Plan 2 for GCC"
"bf95fd32-576a-4742-8d7a-6dc4940b9532" = "Visio Plan 2 for Faculty"
"4016f256-b063-4864-816e-d818aad600c9" = "Viva Topics"
"1e7e1070-8ccb-4aca-b470-d7cb538cb07e" = "Windows 10/11 Enterprise E5 (Original)"
"8efbe2f6-106e-442f-97d4-a59aa6037e06" = "Windows 10/11 Enterprise A3 for faculty"
"d4ef921e-840b-4b48-9a90-ab6698bc7b31" = "Windows 10/11 Enterprise A3 for students"
"7b1a89a9-5eb9-4cf8-9467-20c943f1122c" = "Windows 10/11 Enterprise A5 for faculty"
"cb10e6cd-9da4-4992-867b-67546b1db821" = "Windows 10/11 Enterprise E3"
"6a0f6da5-0b87-4190-a6ae-9bb5a2b9546a" = "Windows 10/11 Enterprise E3"
"488ba24a-39a9-4473-8ee5-19291e71b002" = "Windows 10/11 Enterprise E5"
"938fd547-d794-42a4-996c-1cc206619580" = "Windows 10/11 Enterprise E5 Commercial (GCC Compatible)"
"d13ef257-988a-46f3-8fce-f47484dd4550" = "Windows 10/11 Enterprise E3 VDA"
"816eacd3-e1e3-46b3-83c8-1ffd37e053d9" = "Windows 365 Business 1 vCPU 2 GB 64 GB"
"135bee78-485b-4181-ad6e-40286e311850" = "Windows 365 Business 2 vCPU 4 GB 128 GB"
"805d57c3-a97d-4c12-a1d0-858ffe5015d0" = "Windows 365 Business 2 vCPU 4 GB 256 GB"
"42e6818f-8966-444b-b7ac-0027c83fa8b5" = "Windows 365 Business 2 vCPU 4 GB 64 GB"
"71f21848-f89b-4aaa-a2dc-780c8e8aac5b" = "Windows 365 Business 2 vCPU 8 GB 128 GB"
"750d9542-a2f8-41c7-8c81-311352173432" = "Windows 365 Business 2 vCPU 8 GB 256 GB"
"ad83ac17-4a5a-4ebb-adb2-079fb277e8b9" = "Windows 365 Business 4 vCPU 16 GB 128 GB"
"439ac253-bfbc-49c7-acc0-6b951407b5ef" = "Windows 365 Business 4 vCPU 16 GB 128 GB (with Windows Hybrid Benefit)"
"b3891a9f-c7d9-463c-a2ec-0b2321bda6f9" = "Windows 365 Business 4 vCPU 16 GB 256 GB"
"1b3043ad-dfc6-427e-a2c0-5ca7a6c94a2b" = "Windows 365 Business 4 vCPU 16 GB 512 GB"
"3cb45fab-ae53-4ff6-af40-24c1915ca07b" = "Windows 365 Business 8 vCPU 32 GB 128 GB"
"fbc79df2-da01-4c17-8d88-17f8c9493d8f" = "Windows 365 Business 8 vCPU 32 GB 256 GB"
"8ee402cd-e6a8-4b67-a411-54d1f37a2049" = "Windows 365 Business 8 vCPU 32 GB 512 GB"
"0c278af4-c9c1-45de-9f4b-cd929e747a2c" = "Windows 365 Enterprise 1 vCPU 2 GB 64 GB"
"7bb14422-3b90-4389-a7be-f1b745fc037f" = "Windows 365 Enterprise 2 vCPU 4 GB 64 GB"
"226ca751-f0a4-4232-9be5-73c02a92555e" = "Windows 365 Enterprise 2 vCPU 4 GB 128 GB"
"bce09f38-1800-4a51-8d50-5486380ba84a" = "Windows 365 Enterprise 2 vCPU 4 GB 128 GB (Preview)"
"5265a84e-8def-4fa2-ab4b-5dc278df5025" = "Windows 365 Enterprise 2 vCPU 4 GB 256 GB"
"e2aebe6c-897d-480f-9d62-fff1381581f7" = "Windows 365 Enterprise 2 vCPU 8 GB 128 GB"
"461cb62c-6db7-41aa-bf3c-ce78236cdb9e" = "Windows 365 Enterprise 2 vCPU 8 GB 128 GB (Preview)"
"1c79494f-e170-431f-a409-428f6053fa35" = "Windows 365 Enterprise 2 vCPU 8 GB 256 GB"
"d201f153-d3b2-4057-be2f-fe25c8983e6f" = "Windows 365 Enterprise 4 vCPU 16 GB 128 GB"
"96d2951e-cb42-4481-9d6d-cad3baac177e" = "Windows 365 Enterprise 4 vCPU 16 GB 256 GB"
"bbb4bf6e-3e12-4343-84a1-54d160c00f40" = "Windows 365 Enterprise 4 vCPU 16 GB 256 GB (Preview)"
"0da63026-e422-4390-89e8-b14520d7e699" = "Windows 365 Enterprise 4 vCPU 16 GB 512 GB"
"c97d00e4-0c4c-4ec2-a016-9448c65de986" = "Windows 365 Enterprise 8 vCPU 32 GB 128 GB"
"7818ca3e-73c8-4e49-bc34-1276a2d27918" = "Windows 365 Enterprise 8 vCPU 32 GB 256 GB"
"9fb0ba5f-4825-4e84-b239-5167a3a5d4dc" = "Windows 365 Enterprise 8 vCPU 32 GB 512 GB"
"1f9990ca-45d9-4c8d-8d04-a79241924ce1" = "Windows 365 Shared Use 2 vCPU 4 GB 64 GB"
"90369797-7141-4e75-8f5e-d13f4b6092c1" = "Windows 365 Shared Use 2 vCPU 4 GB 128 GB"
"8fe96593-34d3-49bb-aeee-fb794fed0800" = "Windows 365 Shared Use 2 vCPU 4 GB 256 GB"
"2d21fc84-b918-491e-ad84-e24d61ccec94" = "Windows 365 Shared Use 2 vCPU 8 GB 128 GB"
"2eaa4058-403e-4434-9da9-ea693f5d96dc" = "Windows 365 Shared Use 2 vCPU 8 GB 256 GB"
"1bf40e76-4065-4530-ac37-f1513f362f50" = "Windows 365 Shared Use 4 vCPU 16 GB 128 GB"
"a9d1e0df-df6f-48df-9386-76a832119cca" = "Windows 365 Shared Use 4 vCPU 16 GB 256 GB"
"469af4da-121c-4529-8c85-9467bbebaa4b" = "Windows 365 Shared Use 4 vCPU 16 GB 512 GB"
"f319c63a-61a9-42b7-b786-5695bc7edbaf" = "Windows 365 Shared Use 8 vCPU 32 GB 128 GB"
"fb019e88-26a0-4218-bd61-7767d109ac26" = "Windows 365 Shared Use 8 vCPU 32 GB 256 GB"
"f4dc1de8-8c94-4d37-af8a-1fca6675590a" = "Windows 365 Shared Use 8 vCPU 32 GB 512 GB"
"6470687e-a428-4b7a-bef2-8a291ad947c9" = "Windows Store for Business"
"c7e9d9e6-1981-4bf3-bb50-a5bdfaa06fb2" = "Windows Store for Business EDU Faculty"
"3d957427-ecdc-4df2-aacd-01cc9d519da8" = "Microsoft Workplace Analytics"
}

# Initialize all known service plans as hashtable.
$ServicePlansHashTable = @{

"604ec28a-ae18-4bc6-91b0-11da94504ba9" = "Microsoft 365 Advanced Communications"
"a7c70a41-5e02-4271-93e6-d9b4184d83f5" = "AI Builder capacity add-on"
"113feb6c-3fe4-4440-bddc-54d774bf0318" = "Exchange Foundation"
"0bfc98ed-1dbc-4a97-b246-701754e48b17" = "APP CONNECT"
"f6de4823-28fa-440b-b886-4783fa86ddba" = "Microsoft 365 Audit Platform"
"5f3b1ded-75c0-4b31-8e6e-9b077eaadfd5" = "Microsoft Application Protection and Governance (A)"
"2e6ffd72-52d1-4541-8f6c-938f9a8d4cdc" = "Microsoft Application Protection and Governance (D)"
"80f0ae31-0dfb-425c-b3fc-36f40170eb35" = "Career Coach"
"a1ace008-72f3-4ea0-8dac-33b3a23a2472" = "Microsoft Clipchamp"
"430b908f-78e1-4812-b045-cf83320e7d5d" = "Microsoft Clipchamp Premium"
"f7e5b77d-f293-410a-bae8-f941f19fe680" = "OneDrive for Business (Clipchamp)"
"3e26ee1f-8a5f-4d52-aee2-b81ce45c8f40" = "Microsoft 365 Audio Conferencing"
"c4da7f8a-5ee2-4c99-a7e1-87d2df57f6fe" = "Microsoft Entra BASIC"
"41781fb2-bc02-4b7c-bd55-b576c07bb09d" = "Microsoft Entra ID P1"
"932ad362-64a8-4783-9106-97849a1a30b9" = "CLOUD APP SECURITY DISCOVERY"
"8a256a2b-b617-496d-b51b-e76466e88db0" = "MICROSOFT AZURE MULTI-FACTOR AUTHENTICATION"
"eec0eb4f-6444-4f95-aba0-50c24d67f998" = "Microsoft Entra ID P2"
"bea4c11e-220a-4e6d-8eb8-8ea15d019f90" = "AZURE INFORMATION PROTECTION PREMIUM P1"
"6c57d4b6-3b23-47a5-9bc9-69f17b4947b3" = "Microsoft Entra RIGHTS"
"39b5c996-467e-4e60-bd62-46066f572726" = "Microsoft Invoicing"
"199a5c09-e0ca-4e37-8f7c-b05d533e1ea2" = "Microsoft Bookings"
"dd12a3a8-caec-44f8-b4fb-2f1a864b51e3" = "Common Data Service for Apps File Capacity"
"360bcc37-0c11-4264-8eed-9fa7a3297c9b" = "Common Data Service for Apps Database Capacity"
"1ddffef6-4f69-455e-89c7-d5d72105f915" = "Common Data Service for Apps Database Capacity for Government"
"922ba911-5694-4e99-a794-73aed9bfeec8" = "Exchange Foundation for Government"
"dc48f5c5-e87d-43d6-b884-7ac4a59e7ee9" = "Common Data Service for Apps Log Capacity"
"505e180f-f7e0-4b65-91d4-00d670bbd18c" = "COMMUNICATIONS CREDITS"
"3a117d30-cfac-4f00-84ac-54f8b6a18d78" = "Compliance Manager Premium Assessment Add-On"
"fbdb91e6-7bfd-4a1f-8f7a-d27f4ef39702" = "Defender Threat Intelligence"
"b9f7ce72-67ff-4695-a9d9-5ff620232024" = "Dynamics 365 Customer Service Chat Application Integration for Government"
"9d37aa61-3cc3-457c-8b54-e6f3853aa6b6" = "Dynamics 365 Customer Service Digital Messaging add-on for Government"
"e304c3c3-f86c-4200-b174-1ade48805b22" = "Dynamics 365 Customer Service Digital Messaging application integration for Government"
"ffb878a5-3184-472b-800b-65eadc63d764" = "Dynamics 365 for Customer Service Chat for Government"
"9023fe69-f9e0-4c1e-bfde-654954469162" = "Power Virtual Agents for Chat for Gov"
"e501d49b-1176-4816-aece-2563c0d995db" = "Power Virtual Agents for Digital Messaging for Gov"
"77866113-0f3e-4e6e-9666-b1e25c6f99b0" = "Microsoft Dynamics CRM Online Storage Add-On"
"eeea837a-c885-4167-b3d5-ddde30cbd85f" = "Microsoft Dynamics CRM Online Instance"
"a98b7619-66c7-4885-bdfc-1d9c8c3d279f" = "Microsoft Dynamics CRM Online Additional Test Instance"
"339f4def-5ad8-4430-8d12-da5fd4c769a7" = "Dynamics 365 AI for Market Insights - Free"
"90467813-5b40-40d4-835c-abd48009b1d9" = "Asset Maintenance Add-in"
"d397d6c6-9664-4502-b71c-66f39c400ca4" = "Dynamics 365 Business Central Additional Environment Addon"
"ae6b27b3-fe31-4e77-ae06-ec5fabbc103a" = "Dynamics 365 Business Central Database Capacity"
"920656a2-7dd8-4c83-97b6-a356414dbd36" = "Dynamics 365 for Business Central Essentials"
"7e6d7d78-73de-46ba-83b1-6d25117334ba" = "Flow for Dynamics 365"
"874fc546-6efe-4d22-90b8-5c4e7aa59f4b" = "PowerApps for Dynamics 365"
"170991d7-b98e-41c5-83d4-db2052e1795f" = "Dynamics 365 Business Central External Accountant"
"3f2afeed-6fb5-4bf9-998f-f2912133aead" = "Dynamics 365 Business Central for IWs"
"8e9002c0-a1d8-4465-b952-817d2948e6e2" = "Dynamics 365 Business Central Premium"
"d9a6391b-8970-4976-bd94-5f205007c8d8" = "Dynamics 365 for Team Members"
"52e619e2-2730-439a-b0d3-d09ab7e8b705" = "Power Apps for Dynamics 365"
"1ec58c70-f69c-486a-8109-4b87ce86e449" = "Power Automate for Dynamics 365"
"874d6da5-2a67-45c1-8635-96e8b3e300ea" = "Dynamics 365 for Retail Trial"
"d56f3deb-50d8-465a-bedb-f079817ccac1" = "Dynamics 365 Customer Engagement Plan"
"1412cdc1-d593-4ad1-9050-40c30ad0b023" = "Dynamics 365 Customer Service Insights for CE Plan"
"8c66ef8a-177f-4c0d-853c-d4f219331d09" = "Dynamics 365 for Field Service"
"18fa3aba-b085-4105-87d7-55617b8585e6" = "Dynamics 365 Project Operations CDS"
"97f29a83-1a20-44ff-bf48-5e4ad11f3e51" = "Microsoft Dynamics 365 Customer Voice for Customer Engagement Plan"
"60bf28f9-2b70-4522-96f7-335f5e06c941" = "Power Pages Internal User"
"03acaee3-9492-4f40-aed4-bcb6b32981b6" = "Retired - Microsoft Social Engagement"
"69f07c66-bee4-4222-b051-195095efee5b" = "Dynamics 365 Project Operations"
"1315ade1-0410-450d-b8e3-8050e6da320f" = "Common Data Service"
"0b2c029c-dca0-454a-a336-887285d6ef07" = "Dynamics 365 Guides"
"4f4c7800-298a-4e22-8867-96b17850d4dd" = "Dynamics 365 Remote Assist"
"816971f4-37c5-424a-b12b-b56881f402e7" = "Power Apps for Guides"
"57ff2da0-773e-42df-b2af-ffb7a2317929" = "Microsoft Teams"
"e95bec33-7c88-4a70-8e19-b10bd9d0c014" = "Office for the Web"
"0a05d977-a21a-45b2-91ce-61c240dbafa2" = "Project for Project Operations"
"fafd7243-e5c1-4a3a-9e40-495efcb1d3c3" = "Project Online Desktop Client"
"fe71d6c3-a2ea-4499-9778-da042bf08063" = "Project Online Service"
"5dbe027f-2339-4123-9542-606e4d348a72" = "SharePoint (Plan 2)"
"0b03f40b-c404-40c3-8651-2aceb74365fa" = "Power Apps for Dynamics 365"
"b650d915-9886-424b-a08d-633cede56f57" = "Power Automate for Dynamics 365"
"d04ca659-b119-4a92-b8fc-3ede584a9d65" = "Dataverse for Customer Insights BASE"
"ca00cff5-2568-4d03-bb6c-a653a8f360ca" = "Common Data Service for Customer Insights"
"ee85d528-c4b4-4a99-9b07-fb9a1365dc93" = "Dynamics 365 Customer Insights"
"46c5ea0a-2343-49d9-ae4f-1c268b232d53" = "Microsoft Dynamics 365 Customer Voice for Customer Insights App"
"411b0c93-8f89-455e-a663-c0a3effd12c3" = "Dynamics 365 for Customer Service Voice Add-in for Government"
"cad9c719-36e0-43c7-9506-6886f272d4f0" = "Power Virtual Agents for Customer Service Voice for Government"
"dbe07046-af68-4861-a20d-1c8cbda9194f" = "Customer Voice for Dynamics 365 vTrial"
"47c2b191-a5fb-4129-b690-00c474d2f623" = "Dynamics 365 Customer Service Digital Messaging add-on"
"5b1e5982-0e88-47bb-a95e-ae6085eda612" = "Dynamics 365 Customer Service Insights for CS Enterprise"
"99340b49-fb81-4b1e-976b-8f2ae8e9394f" = "Dynamics 365 for Customer Service"
"f6ec6dfa-2402-468d-a455-89be11116d43" = "Dynamics 365 for Customer Service Voice Add-in"
"a3dce1be-e9ca-453a-9483-e69a5b46ce98" = "Power Virtual Agents for Customer Service Voice"
"2d2f174c-c3cc-4abe-9ce8-4dd86f469ab1" = "Power Virtual Agents for Digital Messaging"
"b3c26516-3b8d-492f-a5a3-64d70ad3f8d0" = "Dynamics 365 Customer Insights Engagement Insights"
"94e5cbf6-d843-4ee8-a2ec-8b15eb52019e" = "Common Data Service for Customer Insights Trial"
"e2bdea63-235e-44c6-9f5e-5b0e783f07dd" = "Dynamics 365 Customer Insights Engagement Insights Viral"
"ed8e8769-94c5-4132-a3e7-7543b713d51f" = "Dynamics 365 Customer Insights Viral Plan"
"fe581650-cf61-4a09-8814-4bd77eca9cb5" = "Microsoft Dynamics 365 Customer Voice for Customer Insights"
"61a2665f-1873-488c-9199-c3d0bc213fdf" = "Dynamics 365 for Customer Service Enterprise Attach"
"dc6643d9-1e72-4dce-9f64-1d6eac1f1c5a" = "Dynamics 365 for Customer Service for Government"
"bb681a9b-58f5-42ee-9926-674325be8aaa" = "Microsoft Dynamics 365 Customer Voice for Customer Service Enterprise for GCC"
"8f9f0f3b-ca90-406c-a842-95579171f8ec" = "Office for the Web for Government"
"fdcb7064-f45c-46fa-b056-7e0e9fdf4bf3" = "Project Online Essentials for Government"
"153f85dd-d912-4762-af6c-d6e0fb4f6692" = "SharePoint Plan 2G"
"2c6af4f1-e7b6-4d59-bbc8-eaa884f42d69" = "Power Automate for Dynamics 365 for Government"
"3089c02b-e533-4b73-96a5-01fa648c3c3c" = "PowerApps for Dynamics 365 for Government"
"ce312d15-8fdf-44c0-9974-a25a177125ee" = "Dynamics 365 AI for Customer Service Virtual Agents Viral"
"3bf52bdf-5226-4a97-829e-5cca9b3f3392" = "Dynamics 365 Customer Service Digital Messaging vTrial"
"94fb67d3-465f-4d1f-a50a-952da079a564" = "Dynamics 365 Customer Service Enterprise vTrial"
"33f1466e-63a6-464c-bf6a-d1787928a56a" = "Dynamics 365 Customer Service Insights vTrial"
"3de81e39-4ce1-47f7-a77f-8473d4eb6d7c" = "Dynamics 365 Customer Service Voice vTrial"
"54b37829-818e-4e3c-a08a-3ea66ab9b45d" = "Power Apps for Dynamics 365 vTrial"
"81d4ecb8-0481-42fb-8868-51536c5aceeb" = "Power Automate for Dynamics 365 vTrial"
"4ade5aa6-5959-4d2c-bf0a-f4c9e2cc00f2" = "Dynamics 365 AI for Customer Service Trial"
"363430d1-e3f7-43bc-b07b-767b6bb95e4b" = "Common Data Service"
"17efdd9f-c22c-4ad8-b48e-3b1f3ee1dc9a" = "Dynamics 365 Customer Voice"
"e212cbc7-0961-4c40-9825-01117710dcb1" = "Microsoft Forms (Plan E5)"
"57a0746c-87b8-4405-9397-df365a9db793" = "Power Automate for Dynamics 365 Customer Voice"
"6929f657-b31b-4947-b4ce-5066c3214f54" = "Dynamics 365 for Customer Service Pro"
"c507b04c-a905-4940-ada6-918891e6d3ad" = "Power Apps for Customer Service Pro"
"0368fc9c-3721-437f-8b7d-3d0f888cdefc" = "Power Automate for Customer Service Pro"
"1259157c-8581-4875-bca7-2ffb18c51bda" = "Project Online Essentials"
"a9dd2dca-10ae-4da2-aaf0-d3fe8a825110" = "Dynamics 365 for Customer Service Pro Attach"
"296820fe-dce5-40f4-a4f2-e14b8feef383" = "Dynamics 365 Customer Voice Base Plan"
"90a816f6-de5f-49fd-963c-df490d73b7b5" = "Microsoft Dynamics 365 Customer Voice Add-on"
"e6e35e2d-2e7f-4e71-bc6f-2f40ed062f5d" = "Dynamics Customer Voice Add-On"
"e9830cfd-e65d-49dc-84fb-7d56b9aa2c89" = "Common Data Service"
"3ca0766a-643e-4304-af20-37f02726339b" = "Microsoft Dynamics 365 Customer Voice USL"
"62edd427-6067-4274-93c4-29afdeb30707" = "Microsoft Dynamics CRM Online Storage Add-On"
"eac6b45b-aa89-429f-a37b-c8ce00e8367e" = "Microsoft Dynamics CRM Online - Portal Add-On"
"1d4e9cb1-708d-449c-9f71-943aa8ed1d6a" = "Microsoft Dynamics CRM Online - Portal Add-On"
"6d99eb83-7b5f-4947-8e99-cc12f1adb399" = "Microsoft Dynamics CRM Online Additional Non-production Instance"
"483cc331-f4df-4a3b-b8ca-fe1a247569f6" = "Microsoft Dynamics CRM Online Instance"
"24435e4b-87d0-4d7d-8beb-63a9b1573022" = "Field Service   Automated Routing Engine Add-On"
"2ba394e0-6f18-4b77-b45f-a5663bbab540" = "RETIRED - Field Service   Automated Routing Engine Add-On"
"2457fe40-65be-48a1-935f-924ad6e62dba" = "Common Data Service Field service Part Time Contractors for Government"
"20d1455b-72b2-4725-8354-a177845ab77d" = "Dynamics 365 Field Service Enterprise vTrial"
"e95d7060-d4d9-400a-a2bd-a244bf0b609e" = "Common Data Service for Dynamics 365 Finance"
"c7657ae3-c0b0-4eed-8c1d-6a7967bd9c65" = "Dynamics 365 for Finance and Operations Enterprise edition - Regulatory Service"
"9f0e1b4e-9b33-4300-b451-b2c662cd4ff7" = "Microsoft Dynamics 365 for Finance"
"2822a3a1-9b8f-4432-8989-e11669a60dc8" = "Dynamics 365 for Case Management"
"79bb0a8d-e686-4e16-ac59-2b3fd0014a61" = "Dynamics 365 for Case Management for Government"
"426ec19c-d5b1-4548-b894-6fe75028c30d" = "Dynamics 365 Customer Service Chat Application Integration"
"f69129db-6dc1-4107-855e-0aaebbcd9dd4" = "Dynamics 365 for Customer Service Chat"
"19e4c3a8-3ebe-455f-a294-4f3479873ae3" = "Power Virtual Agents for Chat"
"67bf4812-f90b-4db9-97e7-c0bbbf7b2d09" = "Microsoft Dynamics 365 Customer Voice for Customer Service Enterprise"
"55c9148b-d5f0-4101-b5a0-b2727cfc0916" = "Dynamics 365 for Field Service Attach"
"9c439259-63b0-46cc-a258-72be4313a42d" = "Microsoft Dynamics 365 Customer Voice for Field Service"
"a9a5be2d-17dd-4d43-ba78-9391e11d20a7" = "Dynamics 365 for Field Service for Government"
"638862ef-afb3-46e4-b292-ed0aad759476" = "Microsoft Dynamics 365 Customer Voice for Field Service for GCC"
"51cf0638-4861-40c0-8b20-1161ab2f80be" = "Dynamics 365 for Marketing Additional Application"
"e626a4ec-1ba2-409e-bf75-9bc0bc30cca7" = "Dynamics 365 for Marketing 50K Addnl Contacts"
"1599de10-5250-4c95-acf2-491f74edce48" = "Dynamics 365 Marketing Sandbox Application AddOn"
"a3a4fa10-5092-401a-af30-0462a95a7ac8" = "Dynamics 365 for Marketing"
"22b657cf-0a9e-467b-8a91-5e31f21bc570" = "Microsoft Dynamics 365 Customer Voice for Marketing Application"
"2824c69a-1ac5-4397-8592-eae51cb8b581" = "Dynamics 365 for Marketing MSE User"
"5d7a6abc-eebd-46ab-96e1-e4a2f54a2248" = "Dynamics 365 for Marketing USL"
"76366ba0-d230-47aa-8087-b6d55dae454f" = "Microsoft Dynamics 365 Customer Voice for Marketing"
"f06754ec-6d72-4bf6-991c-4cb5413d9932" = "Dynamics 365 for Retail Activity"
"aac5a56b-b02e-4608-8014-b076646d4011" = "Dynamics 365 for Talent - Attract Experience Activity"
"db225597-e9c2-4d96-8ace-5424744c80f8" = "Dynamics 365 for Talent - Onboard Experience"
"1f87ee90-5c3a-4cf9-b6fd-e3e8017c26ec" = "Dynamics 365 for Talent Activity"
"6bddf93e-d6f4-4991-b9fc-30cfdf07ee7b" = "Dynamics365 for Operations Activity"
"7df1d500-ca5c-4229-8cea-815bc88798c9" = "Common Data Service for Dynamics 365 Project Operations"
"e564d403-7eaf-4c91-b92f-bb0dc62026e1" = "Dynamics 365 Project Operations CDS Attach"
"fa7675bd-6717-40e7-8172-d0bbcbe1ab12" = "Dynamics 365 Project Operations Attach"
"6d8e07c6-9613-484f-8cc1-a66c5c3979bb" = "Project for Project Operations Attach"
"c7699d2e-19aa-44de-8edf-1736da088ca1" = "SharePoint (Plan 1)"
"1d8c8e0e-4308-4db5-8a41-b129dbdaea20" = "Dynamics 365 for Project Service Automation for Government"
"e98256c5-17d0-4987-becc-e991c52d55c6" = "Microsoft Dynamics 365 Customer Voice for Project Service Automation for GCC"
"45c6831b-ad74-4c7f-bd03-7c2b3fa39067" = "Project Online Desktop Client"
"e57afa78-1f19-4542-ba13-b32cd4d8f472" = "Project Online Service for Government"
"2da8e897-7791-486b-b08f-cc63c8129df7" = "DYNAMICS 365 FOR SALES"
"213be507-d547-4f79-bc2c-6196bc54c4a3" = "Dynamics 365 for Sales for Government"
"33850b82-0a37-4ebb-a0b2-ee163facd716" = "Microsoft Dynamics 365 Customer Voice for Sales Enterprise for GCC"
"8ba1ff15-7bf6-4620-b65c-ecedb6942766" = "Microsoft Viva Sales Premium & Trial"
"a933a62f-c3fb-48e5-a0b7-ac92b94b4420" = "Microsoft Viva Sales Premium with Power Automate"
"fedc185f-0711-4cc0-80ed-0a92da1a8384" = "Dynamics 365 AI for Sales (Embedded)"
"8839ef0e-91f1-4085-b485-62e06e7c7987" = "Microsoft Dynamics 365 Customer Voice for Sales Enterprise"
"b6a8b974-2956-4e14-ae81-f0384c363528" = "Common Data Service for Dynamics 365 Supply Chain Management"
"2bb89402-51e9-4c5a-be33-e954a9dd1ba6" = "Dataverse for IOM"
"b21c777f-c2d5-486e-88f6-fc0a3e474271" = "Dynamics 365 for Supply Chain Management Attach"
"393a0c96-9ba1-4af0-8975-fa2f853a25ac" = "Dynamics 365 Marketing"
"7f636c80-0961-41b2-94da-9642ccf02de0" = "Dynamics 365 Sales Enterprise vTrial"
"456747c0-cf1e-4b0d-940f-703a01b964cc" = "Dynamics 365 Sales Insights vTrial"
"88d83950-ff78-4e85-aa66-abfc787f8090" = "Dynamics 365 for Sales Professional"
"6f9f70ce-138d-49f8-bb8b-2e701b7dde75" = "Power Apps for Sales Pro"
"f944d685-f762-4371-806d-a1f48e5bea13" = "Project Online Essentials"
"dd89efa0-5a55-4892-ba30-82e3f8008339" = "Dynamics 365 for Sales Professional for Government"
"12cf31f8-754f-4efe-87a8-167c19e30831" = "Power Apps for Sales Pro for Government"
"e62ffe5b-7612-441f-a72d-c11cf456d33a" = "Power Automate for Sales Pro for Government"
"73f205fc-6b15-47a5-967e-9e64fdf72d0a" = "Dynamics 365 for Sales Professional Trial"
"db39a47e-1f4f-462b-bf5b-2ec471fb7b88" = "Dynamics 365 for Sales Professional Trial"
"065f3c64-0649-4ec7-9f47-ef5cf134c751" = "Dynamics 365 for Sales Pro Attach"
"1224eae4-0d91-474a-8a52-27ec96a63fe7" = "DYNAMICS 365 FOR SUPPLY CHAIN MANAGEMENT"
"2d925ad8-2479-4bd8-bb76-5b80f1d48935" = "Common Data Service"
"f815ac79-c5dd-4bcc-9b78-d97f7b817d0d" = "Dynamics 365 for Talent: Attract"
"300b8114-8555-4313-b861-0c115d820f50" = "Dynamics 365 for Talent: Onboard"
"5ed38b64-c3b7-4d9f-b1cd-0de18c9c4331" = "Dynamics 365 for HCM Trial"
"c0454a3d-32b5-4740-b090-78c32f48f0ad" = "Dynamics 365 for Retail Team members"
"643d201a-9884-45be-962a-06ba97062e5e" = "Dynamics 365 for Talent - Attract Experience Team Member"
"f2f49eef-4b3f-4853-809a-a055c6103fe0" = "Dynamics 365 for Talent - Onboard Experience"
"d5156635-0704-4f66-8803-93258f8b2678" = "Dynamics 365 for Talent Team members"
"6a54b05e-4fab-40e7-9828-428db3b336fa" = "Dynamics 365 for Team Members"
"f5aa7b45-8a36-4cd1-bc37-5d06dea98645" = "Dynamics_365_for_Operations_Team_members"
"5a94d0aa-ee95-455a-bb38-326e5f134478" = "Dynamics 365 for Team Members for Government"
"47bdde6a-959f-4c7f-8d59-3243e34f1cb3" = "Power Automate for Dynamics 365 Team Members for Government"
"63efc247-5f28-43e3-a2f8-00c183e3f1db" = "PowerApps for Dynamics 365 Team Members for Government"
"ceb28005-d758-4df7-bb97-87a617b93d6c" = "Dynamics 365 for Retail Device"
"2c9fb43e-915a-4d61-b6ca-058ece89fd66" = "Dynamics 365 for Operations Devices"
"d8ba6fb2-c6b1-4f07-b7c8-5f2745e36b54" = "Dynamics 365 for Operations non-production multi-box instance for standard acceptance testing (Tier 2)"
"f6b5efb1-1813-426f-96d0-9b4f7438714f" = "Dynamics 365 for Operations Enterprise Edition - Sandbox Tier 4:Standard Performance Testing"
"056a5f80-b4e0-4983-a8be-7ad254a113c9" = "DYNAMICS 365 P1 TRIAL FOR INFORMATION WORKERS"
"0850ebb5-64ee-4d3a-a3e1-5a97213653b5" = "Common Data Service for Remote Assist"
"3ae52229-572e-414f-937c-ff35a87d4f29" = "Dynamics 365 for Sales Enterprise Attach"
"048a552e-c849-4027-b54c-4c7ead26150a" = "DYNAMICS 365 FOR TALENT: ONBOARD"
"4092fdb5-8d81-41d3-be76-aaba4074530b" = "Dynamics 365 Team Members"
"d1142cfd-872e-4e77-b6ff-d98ec5a51f66" = "COMMON DATA SERVICE"
"65a1ebf4-6732-4f00-9dcb-3d115ffdeecd" = "DYNAMICS 365 FOR TALENT"
"95d2cd7b-1007-484b-8595-5e97e63fe189" = "DYNAMICS 365 FOR_OPERATIONS"
"a9e39199-8369-444b-89c1-5fe65ec45665" = "DYNAMICS 365 FOR RETAIL"
"3a3976ce-de18-4a87-a78e-5e9245e252df" = "Microsoft Entra ID for Education"
"c1ec4a95-1f05-45b3-a911-aa3fa01094f5" = "Microsoft Intune"
"da24caf9-af8e-485c-b7c8-e73336da2693" = "Microsoft Intune for Education"
"a420f25f-a7b3-4ff5-a9d0-5d58f73b537d" = "Windows Store Service"
"5689bec4-755d-4753-8b61-40975025187c" = "AZURE INFORMATION PROTECTION PREMIUM P2"
"2e2ddb96-6af9-4b1d-a3f0-d6ecfd22edb2" = "MICROSOFT CLOUD APP SECURITY"
"14ab5db5-e6c4-4b20-b4bc-13e36fd2227f" = "MICROSOFT DEFENDER FOR IDENTITY"
"9aaf7827-d63c-4b61-89c3-182f06f82e5c" = "Exchange Online (Plan 1)"
"882e1d05-acd1-4ccb-8708-6ee03664b117" = "Mobile Device Management for Office 365"
"5e62787c-c316-451f-b873-1d05acd4d12c" = "To-Do (Plan 1)"
"2078e8df-cff6-4290-98cb-5408261a760a" = "Yammer for Academic"
"31cf2cfc-6b0d-4adc-a336-88b724ed8122" = "Microsoft Azure Rights Management Service"
"e9b4930a-925f-45e2-ac2a-3f7788ca6fdd" = "Exchange Online (Plan 1) for Government"
"efb87545-963c-4e0d-99df-69c6916d9eb0" = "EXCHANGE ONLINE (PLAN 2)"
"176a09a6-7ec5-4039-ac02-b2791c6ba793" = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE ONLINE"
"da040e0a-b393-4bea-bb76-928b3fa1cf5a" = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE SERVER"
"1126bef5-da20-4f07-b45e-ad25d2581aa8" = "EXCHANGE ESSENTIALS"
"4a82b400-a79f-41a4-b4e2-e94f5787b113" = "EXCHANGE ONLINE KIOSK"
"90927877-dcff-4af6-b346-2332c0b15bb7" = "EXCHANGE ONLINE POP"
"326e2b78-9d27-42c9-8509-46c827743a17" = "Exchange Online Protection"
"e2f705fd-2468-4090-8c58-fad6e6b1e724" = "Dynamics 365 Operations Trial Environment"
"3d53f6d9-d6e0-45c1-9575-6acd77692584" = "Microsoft Dynamics CRM Online Government Basic"
"2b8c7c8c-9db5-44a5-a1dd-f4aa5b97b372" = "Microsoft Dynamics CRM Online Professional for Government"
"bf28f719-7844-4079-9c78-c1307898e192" = "Microsoft 365 Defender"
"f20fedf3-f3c3-43c3-8267-2bfdd51c0939" = "Microsoft Defender for Office 365 (Plan 1)"
"8e0c0a52-6a6c-4d40-8370-dd62790dcd70" = "Microsoft Defender for Office 365 (Plan 2)"
"1d0f309f-fdf9-4b2a-9ae7-9c48b91f1426" = "Microsoft Entra ID Basic for Education"
"95b76021-6a53-4741-ab8b-1d1f3d66a95a" = "Common Data Service for Teams"
"a9b86446-fa4e-498f-a92a-41b447e03337" = "Education Analytics"
"c4801e8a-cb58-4c35-aca6-f2dcc106f287" = "Information Barriers"
"2b815d45-56e4-4e3a-b65c-66cb9175b560" = "Information Protection and Governance Analytics   Standard"
"5136a095-5cf0-4aff-bec3-e84448b38ea5" = "Information Protection for Office 365 - Standard"
"33c4f319-9bdd-48d6-9c4d-410b750a4a5a" = "Insights by MyAnalytics"
"43de0ff5-c92c-492b-9116-175376d08c38" = "Microsoft 365 Apps for enterprise"
"292cc034-7b7c-4950-aaf5-943befd3f1d4" = "Microsoft Defender for Endpoint Plan 1"
"9b5de886-f035-4ff2-b3d8-c9127bea3620" = "Microsoft Forms (Plan 2)"
"aebd3021-9f8f-4bf8-bbe3-0ed2f4f047a1" = "Microsoft Kaizala Pro"
"b737dad2-2f6c-4c65-90e3-ca563267e8b9" = "Microsoft Planner"
"94065c59-bc8e-4e8b-89e5-5138d471eaff" = "Microsoft Search"
"8c7d2df8-86f0-4902-b2ed-a0458298f3b3" = "Microsoft StaffHub"
"9e700747-8b1d-45e5-ab8d-ef187ceec156" = "Microsoft Stream for Office 365 E3"
"4c246bbc-f513-4311-beff-eba54c353256" = "Minecraft Education Edition"
"db4d623d-b514-490b-b7ef-8885eee514de" = "Nucleus"
"8c098270-9dd4-4350-9b30-ba4703f3b36b" = "Office 365 Cloud App Security"
"e03c7e47-402c-463c-ab25-949079bedb21" = "Office for the Web for Education"
"31b4e2fc-4cd6-4e7d-9c1b-41407303bd66" = "Project for Office (Plan E3)"
"500b6a2a-7a50-4f40-b5f9-160e5b8c2f48" = "School Data Sync (Plan 2)"
"63038b2c-28d0-45f6-bc36-33062963b498" = "SharePoint (Plan 2) for Education"
"0feaeb32-d00e-4d66-bd5a-43b5b83db82c" = "Skype for Business Online (Plan 2)"
"a23b959c-7ce8-4e57-9140-b90eb88a9e97" = "Sway"
"c87f142c-d1e9-4363-8630-aaea9c4d9ae5" = "To-Do (Plan 2)"
"b76fb638-6ba6-402a-b9f9-83d28acb3d86" = "Viva Learning Seeded"
"94a54592-cd8b-425e-87c6-97868b000b91" = "Whiteboard (Plan 2)"
"795f6fe0-cc4d-4773-b050-5dde4dc704c9" = "Universal Print"
"e7c91390-7625-45be-94e0-e16907e03118" = "Windows 10/11 Enterprise"
"7bf960f6-2cd9-443a-8046-5dbff9558365" = "Windows Update for Business Deployment Service"
"4ff01e01-1ba7-4d71-8cf8-ce96c3bbcf14" = "Common Data Service"
"c68f8d98-5534-41c8-bf36-22fa496fa792" = "Power Apps for Office 365"
"76846ad7-7776-4c40-a281-a386362dd1b9" = "Power Automate for Office 365"
"041fe683-03e4-45b6-b1af-c0cdc516daee" = "Power Virtual Agents for Office 365"
"b67adbaf-a096-42c9-967e-5a84edbe0086" = "Universal Print Without Seeding"
"a4c6cf29-1168-4076-ba5c-e8fe0e62b17e" = "Remote help"
"8d77e2d9-9e28-4450-8431-0def64078fc5" = "Microsoft 365 Apps for Enterprise (Unattended)"
"afa73018-811e-46e9-988f-f75d2b1b8430" = "Common Data Service for Teams"
"9f431833-0334-42de-a7dc-70aa40db46db" = "Customer Lockbox"
"cd31b152-6326-4d1b-ae1b-997b625182e6" = "Data Classification in Microsoft 365"
"d9fa6af4-e046-4c89-9226-729a0786685d" = "Information Protection and Governance Analytics - Premium"
"efb0351d-3b08-4503-993d-383af8de41e3" = "Information Protection for Office 365 - Premium"
"2f442157-a11c-46b9-ae5b-6e39ff4e5849" = "Microsoft 365 Advanced Auditing"
"a413a9ff-720c-4822-98ef-2f37c2a21f4c" = "Microsoft 365 Communication Compliance"
"4828c8ec-dc2e-4779-b502-87ac9ce28ab7" = "Microsoft 365 Phone System"
"6dc145d6-95dd-4191-b9c3-185575ee6f6b" = "Microsoft Communications DLP"
"6db1f1db-2b46-403f-be40-e39395f08dbb" = "Microsoft Customer Key"
"46129a58-a698-46f0-aa5b-17f6586297d9" = "Microsoft Data Investigations"
"531ee2f8-b1cb-453b-9c21-d2180d014ca5" = "Microsoft Excel Advanced Analytics"
"96c1e14a-ef43-418d-b115-9636cdaa8eed" = "Microsoft Forms (Plan 3)"
"e26c2fcc-ab91-4a61-b35c-03cdc8dddf66" = "Microsoft Information Governance"
"d587c7a3-bda9-4f99-8776-9bcf59c84f75" = "Microsoft Insider Risk Management"
"0898bdbb-73b0-471a-81e5-20f1fe4dd66e" = "Microsoft Kaizala Pro"
"d2d51368-76c9-4317-ada2-a12c004c432f" = "Microsoft ML-Based Classification"
"34c0d7a0-a70f-4668-9238-47f9fc208882" = "Microsoft MyAnalytics (Full)"
"65cc641f-cccd-4643-97e0-a17e3045e541" = "Microsoft Records Management"
"6c6042f5-6f01-4d67-b8c1-eb99d36eed3e" = "Microsoft Stream for Office 365 E5"
"4de31727-a228-4ec3-a5bf-8e45b5ca48cc" = "Office 365 Advanced eDiscovery"
"b1188c4c-1b36-4018-b48b-ee07604f6feb" = "Office 365 Privileged Access Management"
"bf6f5520-59e3-4f82-974b-7dbbc4fd27c7" = "Office 365 SafeDocs"
"9c0dab89-a30c-4117-86e7-97bda240acd2" = "Power Apps for Office 365 (Plan 3)"
"70d33638-9c74-4d01-bfd3-562de28bd4ba" = "Power BI Pro"
"617b097b-4b93-4ede-83de-5f075bb5fb2f" = "Premium Encryption in Office 365"
"b21a6b06-1988-436e-a07b-51ec6d9f52ad" = "Project for Office (Plan E5)"
"41fcdd7d-4733-4863-9cf4-c65b83ce2df4" = "Microsoft Communications Compliance"
"9d0c4ee5-e4a1-4625-ab39-d82b619b1a34" = "Microsoft Insider Risk Management"
"3fb82609-8c27-4f7b-bd51-30634711ee67" = "To-Do (Plan 3)"
"4a51bca5-1eff-43f5-878c-177680f191af" = "Whiteboard (Plan 3)"
"871d91ec-ec1a-452b-a83f-bd76c7d770ef" = "Microsoft Defender for Endpoint"
"64bfac92-2b17-4482-b5e5-a0304429de3e" = "Microsoft Endpoint DLP"
"28b0fa46-c39a-4188-89e2-58e979a6b014" = "Common Data Service"
"07699545-9485-468e-95b6-2fca3738be01" = "Power Automate for Office 365"
"ded3d325-1bdc-453e-8432-5bac26d7a014" = "Power Virtual Agents for Office 365"
"159f4cd6-e380-449f-a816-af1a9ef76344" = "MICROSOFT FORMS (PLAN E1)"
"094e7854-93fc-4d55-b2c0-3ab5369ebdc1" = "OFFICE 365 BUSINESS"
"13696edf-5a08-49f6-8134-03083ed8ba30" = "ONEDRIVESTANDARD"
"3c994f28-87d5-4273-b07a-eb6190852599" = "Microsoft 365 Apps for Enterprise (Device)"
"f544b08d-1645-4287-82de-8d91f37c02a1" = "MICROSOFT 365 AUDIO CONFERENCING FOR GOVERNMENT"
"f1e3613f-3818-4254-9b5e-f02d803384e0" = "Microsoft 365 Audio Conferencing for GCCHigh"
"c85e4b03-254a-453b-af72-167a53f38530" = "Microsoft 365 Audio Conferencing - GCCHigh Tenant"
"bb038288-76ab-49d6-afc1-eaa6c222c65a" = "Microsoft 365 Audio Conferencing Pay-Per-Minute"
"0f9b09cb-62d1-4ff4-9129-43f4996f83f4" = "FLOW FOR OFFICE 365"
"c63d4d19-e8cb-460e-b37c-4d6c34603745" = "OFFICEMOBILE_SUBSCRIPTION"
"92f7a6f3-b89b-4bbd-8c30-809e6da5ad1c" = "POWERAPPS FOR OFFICE 365"
"7547a3fe-08ee-4ccb-b430-5077c5041653" = "YAMMER_ENTERPRISE"
"a82fbf69-b4d7-49f4-83a6-915b2cf354f4" = "Viva Engage Core"
"41bf139a-4e60-409f-9346-a1361efc6dfb" = "YAMMER MIDSIZE"
"bed136c6-b799-4462-824d-fc045d3a9d25" = "Common Data Service for Teams"
"6f23d6a9-adbf-481c-8538-b4c095654487" = "Microsoft 365 Lighthouse (Plan 1)"
"54fc630f-5a40-48ee-8965-af0503c1386e" = "Microsoft Kaizala Pro"
"a55dfd10-0864-46d9-a3cd-da5991a3e0e2" = "Project for Office (Plan E1)"
"3c53ea51-d578-46fa-a4c0-fd0a92809a60" = "Stream for Office 365"
"b8afc642-032e-4de5-8c0a-507a7bba7e5d" = "Whiteboard (Plan 1)"
"40b010bb-0b69-4654-ac5e-ba161433f4b4" = "Common Data Service"
"0683001c-0492-4d59-9515-d9a6426b5813" = "Power Virtual Agents for Office 365"
"dcf9d2f4-772e-4434-b757-77a453cfbc02" = "Avatars for Teams"
"3efbd4ed-8958-4824-8389-1321f8730af8" = "Avatars for Teams (additional)"
"0d0c0d31-fae7-41f2-b909-eaf4d7f26dba" = "Commercial data protection for Microsoft Copilot"
"c4b8c31a-fb44-4c65-9837-a21f55fcabda" = "Microsoft Loop"
"5bfe124c-bbdc-4494-8835-f1297d457d79" = "RETIRED - Outlook Customer Manager"
"9bec7e34-c9fa-40b7-a9d1-bd6d1165c7ed" = "Data Loss Prevention"
"d55411c9-cfff-40a9-87c7-240f14df7da5" = "Microsoft 365 Lighthouse (Plan 2)"
"bfc1bbd9-981b-4f71-9b82-17c35fd0e2a4" = "Microsoft Defender for Business"
"276d6e8a-f056-4f70-b7e8-4fc27f79f809" = "Office Shared Computer Activation"
"c948ea65-2053-4a5a-8a62-9eaaaf11b522" = "Purview Discovery"
"8e229017-d77b-43d5-9305-903395523b99" = "Windows 10/11 Business"
"de377cbc-0019-4ec2-b77c-3f223947e102" = "Azure Active Directory"
"8e9ff0ff-aa7a-4b20-83c1-2f636b600ac2" = "Microsoft Intune"
"743dd19e-1ce3-4c62-a3ad-49ba8f63a2f6" = "Microsoft Stream for Office 365 E1"
"4ed3ff63-69d7-4fb7-b984-5aec7f605ca8" = "Microsoft 365 Domestic Calling Plan"
"54a152dc-90de-4996-93d2-bc47e670fc06" = "MICROSOFT 365 DOMESTIC CALLING PLAN (120 min)"
"3c8a8792-7866-409b-bb61-1b20ace0368b" = "Domestic Calling for Government"
"2789c901-c14e-48ab-a76a-be334d9d793a" = "Microsoft Forms (Plan E3)"
"21b439ba-a0ca-424f-a6cc-52f954a5b111" = "Windows 10/11 Enterprise (Original)"
"9a6eeb79-0b4b-4bf0-9808-39d99a2cd5a3" = "Windows Autopatch"
"fd500458-c24c-478e-856c-a6067a8376cd" = "Microsoft Teams for DOD (AR)"
"9953b155-8aef-4c56-92f3-72b0487fce41" = "Microsoft Teams for GCCHigh (AR)"
"3ec18638-bd4c-4d3b-8905-479ed636b83e" = "Customer Lockbox (A)"
"a6520331-d7d4-4276-95f5-15c0933bc757" = "Graph Connectors Search with Index"
"99cd49a9-0e54-4e07-aea1-d8d9f5f704f5" = "Defender for IoT - Enterprise IoT Security"
"16935b20-87c0-4908-934a-22aa267d0d26" = "Microsoft 365 Domestic Calling Plan (120 min) at User Level"
"6b5b6a67-fc72-4a1f-a2b5-beecf05de761" = "SharePoint (Plan 1)"
"cf1b2895-e3fd-4b33-9594-2ab924104547" = "Microsoft Forms (Plan E5) for GCCHigh"
"fc9f7921-4ca5-42c6-8533-1b84c4ee496b" = "Microsoft Search for Arlington"
"b50a9096-5b07-4ded-a5e4-a492fb94b6ee" = "Power Apps for Office 365 for GCCHigh"
"ee939cf0-7cd1-4262-9f72-9eaa45dbba69" = "Power Automate for Office 365 for GCCHigh"
"6a76346d-5d6e-4051-9fe3-ed3f312b5597" = "Azure Rights Management"
"3ffba0d2-38e5-4d5e-8ec0-98f2b05c09d9" = "Microsoft Stream for O365 K SKU"
"902b47e5-dcb2-4fdc-858b-c63a90a2bdb9" = "SharePoint Online Kiosk"
"afc06cb0-b4f4-4473-8286-d644f70d8faf" = "Skype for Business Online (Plan 1)"
"ca6e61ec-d4f4-41eb-8b88-d96e0e14323f" = "Common Data Service"
"90db65a7-bf11-4904-a79f-ef657605145b" = "Common Data Service for Teams"
"f07046bd-2a3c-4b96-b0be-dea79d7cbfb8" = "Microsoft Forms (Plan F1)"
"73b2a583-6a59-42e3-8e83-54db46bc3278" = "Microsoft Kaizala Pro"
"7f6f28c2-34bb-4d4b-be36-48ca2e77e1ec" = "Project for Office (Plan F)"
"80873e7a-cd2a-4e67-b061-1b5381a676a5" = "To-Do (Firstline)"
"36b29273-c6d0-477a-aca6-6fbe24f538e3" = "Whiteboard (Firstline)"
"e041597c-9c7f-4ed9-99b0-2663301576f7" = "Windows 10 Enterprise E3 (Local Only)"
"e0287f9f-e222-4f98-9a83-f379e249159a" = "Power Apps for Office 365 F3"
"bd91b1a4-9f94-4ecf-b45b-3a65e5c8128a" = "Power Automate for Office 365 F3"
"ba2fdb48-290b-4632-b46a-e4ecc58ac11a" = "Power Virtual Agents for Office 365"
"a42de799-58ae-4e6a-aa1d-948e7abec726" = "Microsoft Teams Kiosk"
"1b66aedf-8ca1-4f73-af76-ec76c6180f98" = "Azure Information Protection Premium P1 for GCC"
"29007dd3-36c0-4cc2-935d-f5bca2c2c473" = "Common Data Service - O365 F1"
"5e05331a-0aec-437e-87db-9ef5934b5771" = "Common Data Service for Teams_F1 GCC"
"88f4d7ef-a73b-4246-8047-516022144c9f" = "Exchange Online (Kiosk) for Government"
"bfd4133a-bbf3-4212-972b-60412137c428" = "Forms for Government (Plan F1)"
"d65648f1-9504-46e4-8611-2658763f28b8" = "Microsoft Stream for O365 for Government (F1)"
"304767db-7d23-49e8-a945-4a7eb65f9f28" = "Microsoft Teams for Government"
"5b4ef465-7ea1-459a-9f91-033317755a51" = "Office 365 Planner for Government"
"4ccb60ee-9523-48fd-8f63-4b090f1ad77a" = "Office Mobile Apps for Office 365 for GCC"
"49f06c3d-da7d-4fa0-bcce-1458fdd18a59" = "Power Apps for Office 365 F3 for Government"
"5d32692e-5b24-4a59-a77e-b2a8650e25c1" = "Power Automate for Office 365 F3 for Government"
"b1aeb897-3a19-46e2-8c27-a609413cf193" = "SharePoint KioskG"
"8a9f17f1-5872-44e8-9b11-3caade9dc90f" = "Skype for Business Online (Plan 1) for Government"
"6ebdddb7-8e55-4af2-952b-69e77262f96c" = "Microsoft Defender for Cloud Apps for DOD"
"89b5d3b1-3855-49fe-b46c-87c66dbc1526" = "Customer Lockbox for Government"
"d1cbfb67-18a8-4792-b643-630b7f19aad1" = "Office 365 Advanced eDiscovery for Government"
"bce5e5ca-c2fd-4d53-8ee2-58dfffed4c10" = "Common Data Service for Teams"
"8c3069c0-ccdb-44be-ab77-986203a67df2" = "Exchange Online (Plan 2) for Government"
"b74d57b2-58e9-484a-9731-aeccbba954f0" = "Graph Connectors Search with Index (Microsoft Viva Topics)"
"de9234ff-6483-44d9-b15e-dca72fdd27af" = "Microsoft 365 Apps for enterprise G"
"db23fce2-a974-42ef-9002-d78dd42a0f22" = "Microsoft 365 Phone System for Government"
"493ff600-6a2b-4db6-ad37-a7d4eb214516" = "Microsoft Defender for Office 365 (Plan 1) for Government"
"900018f1-0cdb-4ecb-94d4-90281760fdc6" = "Microsoft Defender for Office 365 (Plan 2) for Government"
"843da3a8-d2cc-4e7a-9e90-dc46019f964c" = "Microsoft Forms for Government (Plan E5)"
"208120d1-9adb-4daf-8c22-816bd5d237e7" = "Microsoft MyAnalytics for Government (Full)"
"944e9726-f011-4353-b654-5f7d2663db76" = "Power BI Pro for Government"
"9b7c50ec-cd50-44f2-bf48-d72de6f90717" = "Project for Government (Plan E5)"
"a31ef4a2-f787-435e-8335-e47eb0cafc94" = "Skype for Business Online (Plan 2) for Government"
"92c2089d-9a53-49fe-b1a6-9e6bdf959547" = "Stream for Office 365  for Government (E5)"
"5400a66d-eaa5-427d-80f2-0f26d59d8fce" = "Azure Information Protection Premium P2 for GCC"
"a7d3fb37-b6df-4085-b509-50810d991a39" = "Common Data Service"
"0eacfc38-458a-40d3-9eab-9671258f1a3e" = "Power Apps for Office 365 for Government"
"8055d84a-c172-42eb-b997-6c2ae4628246" = "Power Automate for Office 365 for Government"
"f0ff6ac6-297d-49cd-be34-6dfef97f0c28" = "Immersive spaces for Teams"
"a70bbf38-cdda-470d-adb8-5804b8770f41" = "Common Data Service for Teams"
"6e5b7995-bd4f-4cbd-9d19-0e32010c72f0" = "Insights by MyAnalytics for Government"
"24af5f65-d0f3-467b-9f78-ea798c4aeffc" = "Microsoft Forms for Government (Plan E3)"
"e7d09ae4-099a-4c34-a2a2-3e166e95c44a" = "Project for Government (Plan E3)"
"2c1ada27-dbaa-46f9-bda6-ecb94445f758" = "Stream for Office 365 for Government (E3)"
"06162da2-ebf9-4954-99a0-00fee96f95cc" = "Common Data Service"
"0a20c815-5e81-4727-9bdc-2b5a117850c3" = "Power Apps for Office 365 for Government"
"c537f360-6a00-4ace-a7f5-9128d0ac1e4b" = "Power Automate for Office 365 for Government"
"18dfd9bd-5214-4184-8123-c9822d81a9bc" = "Microsoft 365 Apps for enterprise (unattended) for GCC"
"cca845f9-fd51-4df6-b563-976a37c56ce0" = "MICROSOFT BUSINESS CENTER"
"82d30987-df9b-4486-b146-198b21d164c7" = "Graph Connectors in Microsoft 365 Copilot"
"931e4a88-a67f-48b5-814f-16a5f1e6028d" = "Intelligent Search"
"3f30311c-6b1e-48a4-ab79-725b469da960" = "Microsoft 365 Chat"
"b95945de-b3bd-46db-8437-f2beb6ea2347" = "Microsoft 365 Copilot in Microsoft Teams"
"a62f8878-de10-42f3-b68f-6149a25ceb97" = "Microsoft 365 Copilot in Productivity Apps"
"89f1c4c8-0878-40f7-804d-869c9128ab5d" = "Power Platform Connectors in Microsoft 365 Copilot"
"c1c902e3-a956-4273-abdb-c92afcd027ef" = "MCS - BizApps_Cloud for Sustainability_vTrial"
"17ab22cd-a0b3-4536-910a-cb6eb12696c0" = "Common Data Service"
"1689aade-3d6a-4bfc-b017-46d2672df5ad" = "MDE_SecurityManagement"
"bf36ca64-95c6-4918-9275-eb9f4ce2c04f" = "MICROSOFT DYNAMICS CRM ONLINE BASIC"
"61d18b02-6889-479f-8f36-56e6e0fe5792" = "SecOps Investigation for MDI"
"36810a13-b903-490a-aa45-afbeb7540832" = "Microsoft Defender Vulnerability Management"
"f9646fb2-e3b2-4309-95de-dc4833737456" = "MICROSOFT DYNAMICS CRM ONLINE PROFESSIONA"
"3413916e-ee66-4071-be30-6f94d4adfeda" = "MICROSOFT DYNAMICS MARKETING SALES COLLABORATION - ELIGIBILITY CRITERIA APPLY"
"3e58e97c-9abe-ebab-cd5f-d543d1529634" = "MICROSOFT SOCIAL ENGAGEMENT PROFESSIONAL - ELIGIBILITY CRITERIA APPLY"
"e866a266-3cff-43a3-acca-0c90a7e00c8b" = "Entra Identity Governance"
"2049e525-b859-401b-b2a0-e0a31c4b1fe4" = "Power BI (free)"
"d736def0-1fde-43f0-a5be-e3f8b2de6e41" = "MS IMAGINE ACADEMY"
"d216f254-796f-4dab-bbfa-710686e646b9" = "Microsoft Intune G"
"3e170737-c728-4eae-bbb9-3f3360f7184c" = "Microsoft Intune Plan 1"
"d8c638e2-9508-40e3-9877-feb87603837b" = "Common Data Service - DEV VIRAL"
"c7ce3f26-564d-4d3a-878d-d8ab868c85fe" = "Flow for Developer"
"a2729df7-25f8-4e63-984b-8a8484121554" = "PowerApps for Developer"
"50e68c76-46c6-4674-81f9-75456511b170" = "Flow Free"
"d20bfa21-e9ae-43fc-93c2-20783f0840c3" = "Flow P2 Viral"
"d5368ca3-357e-4acb-9c21-8495fb025d1f" = "PowerApps Trial"
"6ea4c1ef-c259-46df-bce2-943342cd3cb2" = "Common Data Service - P2"
"56be9436-e4b2-446c-bb7f-cc15d16cca4d" = "Power Automate (Plan 2)"
"2a4baa0e-5e99-4c38-b1f2-6864960f1bd1" = "Intune Advanced endpoint analytics"
"bb73f429-78ef-4ff2-83c8-722b04c3e7d1" = "Intune Endpoint Privilege Management"
"d9923fe3-a2de-4d29-a5be-e3e83bb786be" = "Intune Plan 2"
"a6e407da-7411-4397-8a2e-d9b52780849e" = "Microsoft Tunnel for Mobile Application Management"
"00527d7f-d5bc-4c2a-8d1e-6c0de2410c81" = "Power Apps (Plan 2)"
"507172c0-6001-4f4f-80e7-f350507af3e5" = "Microsoft Dynamics 365 Customer Voice for Relationship Sales"
"56e3d4ca-2e31-4c3f-8d57-89c1d363503b" = "Microsoft Relationship Sales solution"
"acffdce6-c30f-4dc2-81c0-372e33c515ec" = "MICROSOFT STREAM"
"d3a458d0-f10d-48c2-9e44-86f3f684029e" = "Microsoft Stream Plan 2"
"83bced11-77ce-4071-95bd-240133796768" = "Microsoft Stream Storage Add-On"
"c46c42af-d654-4385-8c85-29a84f3dfb22" = "MCS - BizApps - Cloud for Sustainability USL"
"5ffd371c-037a-41a2-98a3-6452f8c5de17" = "Power Apps for Cloud for Sustainability USL"
"ccbe468e-7973-442c-8ec4-5fbe16438711" = "Power Automate for Cloud for Sustainability USL"
"9974d6cf-cd24-4ba2-921c-e2aa687da846" = "Microsoft Teams Audio Conferencing with dial-out to select geographies"
"617d9209-3b90-4879-96e6-838c42b2701d" = "MCO FREE FOR MICROSOFT TEAMS (FREE)"
"4fa4026d-ce74-4962-a151-8e96d57ea8e4" = "MICROSOFT TEAMS (FREE)"
"bd6f2ac2-991a-49f9-b23c-18c96a02c228" = "TEAMS FREE SERVICE"
"f4f2f6de-6830-442b-a433-e92249faebe2" = "Microsoft Teams Essentials"
"4495894f-534f-41ca-9d3b-0ebf1220a423" = "OneDrive for Business (Basic 2)"
"42a3ec34-28ba-46b6-992f-db53a675ac5b" = "MICROSOFT TEAMS"
"ed777b71-af04-42ca-9798-84344c66f7c6" = "SKYPE FOR BUSINESS CLOUD PBX FOR SMALL AND MEDIUM BUSINESS"
"f47330e9-c134-43b3-9993-e7f004506889" = "Microsoft 365 Phone Standard Resource Account"
"0628a73f-3b4a-4989-bd7b-0f8823144313" = "Microsoft 365 Phone Standard Resource Account for Government"
"85704d55-2e73-47ee-93b4-4b8ea14db92b" = "Microsoft eCDN"
"0504111f-feb8-4a3c-992a-70280f9a2869" = "Microsoft Teams Premium Intelligent"
"cc8c0802-a325-43df-8cba-995d0c6cb373" = "Microsoft Teams Premium Personalized"
"f8b44f54-18bb-46a3-9658-44ab58712968" = "Microsoft Teams Premium Secure"
"9104f592-f2a7-4f77-904c-ca5a5715883f" = "Microsoft Teams Premium Virtual Appointment"
"711413d0-b36e-4cd4-93db-0a50a4ab7ea3" = "Microsoft Teams Premium Virtual Appointments"
"78b58230-ec7e-4309-913c-93a45cc4735b" = "Microsoft Teams Premium Webinar"
"8081ca9c-188c-4b49-a8e5-c23b5e9463a8" = "Teams Room Basic"
"ec17f317-f4bc-451e-b2da-0167e5c260f9" = "Teams Room Pro"
"ecc74eae-eeb7-4ad5-9c88-e8b2bfca75b8" = "Microsoft Teams Rooms Pro Management"
"b83a66d4-f05f-414d-ac0f-ea1c5239c42b" = "Microsoft Threat Experts - Experts on Demand"
"b44c6eaf-5c9f-478c-8f16-8cea26353bfb" = "Viva Goals"
"6b270342-093e-4015-8c5c-224561532fbf" = "Viva Glint"
"b622badb-1b45-48d5-920f-4b27a2c0996c" = "Microsoft Viva Insights"
"ff7b261f-d98b-415b-827c-42a3fdf015af" = "Microsoft Viva Insights Backend"
"c815c93d-0759-4bb8-b857-bc921a71be83" = "Microsoft Viva Topics"
"43304c6a-1d4e-4e0b-9b06-5b2a2ff58a90" = "Viva Engage Communities and Communications"
"c244cc9e-622f-4576-92ea-82e233e44e36" = "Viva Engage Knowledge"
"7162bd38-edae-4022-83a7-c5837f951759" = "Viva Learning"
"897d51f1-2cfa-4848-9b30-469149f5e68e" = "Exchange Online Multi-Geo"
"735c1d98-dd3f-4818-b4ed-c8052e18e62d" = "SharePoint Multi-Geo"
"41eda15d-6b52-453b-906f-bc4a5b25a26b" = "Teams Multi-Geo"
"7dbc2d88-20e2-4eb6-b065-4510b38d6eb2" = "Nonprofit Portal"
"c33802dd-1b50-4b9a-8bb9-f13d2cdeadac" = "School Data Sync (Plan 1)"
"0a4983bb-d3e5-4a09-95d8-b2d0127b3df5" = "SharePoint (Plan 1) for Education"
"e5bb877f-6ac9-4461-9e43-ca581543ab16" = "SHAREPOINTSTORAGE_GOV"
"be5a7ed5-c598-4fcd-a061-5e6724c68a58" = "Office 365 Extra File Storage"
"a361d6e2-509e-4e25-a8ad-950060064ef4" = "SHAREPOINT FOR DEVELOPER"
"527f7cdd-0e86-4c47-b879-f5fd357a3ac6" = "OFFICE ONLINE FOR DEVELOPER"
"27216c54-caf8-4d0d-97e2-517afb5c08f6" = "SKYPE FOR BUSINESS ONLINE (PLAN 3)"
"59fb5884-fdec-40bf-aa7f-89e2bae79a7a" = "Microsoft Forms (Plan F1) for GCCHigh"
"b9f1a92f-d4c7-477b-b64c-e23d7b4e8cf9" = "Power Apps for Office 365 F3 for GCCHigh"
"1db85bca-cd60-4bf5-ae54-641e0778a532" = "Power Automate for Office 365 F3 for GCCHigh"
"8eb5e9bc-783f-4425-921a-c65f45dd72c6" = "Common Data Service - O365 P1 GCC"
"959e5dec-6522-4d44-8349-132c27c3795a" = "Common Data Service for Teams_P1 GCC"
"f4cba850-4f34-4fd2-a341-0fddfdce1e8f" = "Forms for Government (Plan E1)"
"15267263-5986-449d-ac5c-124f3b49b2d6" = "Microsoft Stream for O365 for Government (E1)"
"c42aa49a-f357-45d5-9972-bc29df885fee" = "Power Apps for Office 365 for Government"
"ad6c8870-6356-474c-901c-64d7da8cea48" = "Power Automate for Office 365 for Government"
"f9c43823-deb4-46a8-aa65-8b551f0c4f8a" = "SharePoint Plan 1G"
"fc52cc4b-ed7d-472d-bbe7-b081c23ecc56" = "EXCHANGE ONLINE PLAN"
"b2669e95-76ef-4e7e-a367-002f60a39f3e" = "SKYPE FOR BUSINESS ONLINE (PLAN 2) FOR MIDSIZ"
"d42bdbd6-c335-4231-ab3d-c8f348d5aff5" = "EXCHANGE ONLINE (P1)"
"70710b6b-3ab4-4a38-9f6d-9f169461650a" = "SKYPE FOR BUSINESS ONLINE (PLAN P1)"
"a1f3d0a8-84c0-4ae0-bae4-685917b8ab48" = "SHAREPOINTLITE"
"8ca59559-e2ca-470b-b7dd-afd8c0dee963" = "OFFICE 365 SMALL BUSINESS SUBSCRIPTION"
"83837d9c-c21a-46a0-873e-d834c94015d6" = "Common Data Service for Project for GCC"
"7251de8f-ecfb-481e-bcff-4af4f1a4573c" = "Data integration for Project with Power Automate for GCC"
"49c7bc16-7004-4df6-8cd5-4ec48b7e9ea0" = "Project P3 for GOV"
"16687e20-06f9-4577-9cc0-34a2704260fc" = "Data integration for Project with Power Automate for GCC"
"afcafa6a-d966-4462-918c-ec0b4e0fe642" = "ONEDRIVEENTERPRISE"
"5d7a2e9a-4ee5-4f1c-bc9f-abc481bf39d8" = "AI Builder capacity Per App add-on"
"ce361df2-f2a5-4713-953f-4050ba09aad8" = "Common Data Service for Government"
"37396c73-2203-48e6-8be1-d882dae53275" = "Common Data Service for Government"
"684a2229-5c57-43ab-b69f-f86fe8997358" = "Common Data Service for Project P5 for GCC"
"91f50f7b-2204-4803-acac-5cf5668b8b39" = "DO NOT USE - AI Builder capacity Per User add-on"
"06879193-37cc-4976-8991-f8165c994ce7" = "Power Automate P2 for Dynamics 365 for Government"
"51729bb5-7564-4927-8df8-9f5b12279cf3" = "PowerApps Plan 2 for Dynamics 365 for Government"
"0b4346bb-8dc3-4079-9dfc-513696f56039" = "LOGIC FLOWS"
"2c4ec2dc-c62d-4167-a966-52a3e6374015" = "MICROSOFT POWER VIDEOS BASIC"
"e61a2945-1d4e-4523-b6e7-30ba39d20f32" = "MICROSOFT POWERAPPS"
"94a669d1-84d5-4e54-8462-53b0ae2c8be5" = "CDS Per app baseline access"
"dd14867e-8d31-4779-a595-304405f5ad39" = "Flow per app baseline access"
"35122886-cef5-44a3-ab36-97134eabd9ba" = "PowerApps per app baseline access"
"ee493f70-a3b3-4204-9511-e3f6083b8df3" = "CDS Power Apps Per App Custom GCC"
"be6e5cba-3661-424c-b79a-6d95fa1d849a" = "Power Apps per App Plan for Government"
"8e2c2c3d-07f6-4da7-86a9-e78cc8c2c8b9" = "Power Automate for Power Apps per App Plan for Government"
"9f2f00ad-21ae-4ceb-994b-d8bc7be90999" = "CDS PowerApps per app plan"
"b4f657ff-d83e-4053-909d-baa2b595ec97" = "Power Apps per App Plan"
"c539fa36-a64e-479a-82e1-e40ff2aa83ee" = "Power Automate for Power Apps per App Plan"
"6f0e9100-ff66-41ce-96fc-3d8b7ad26887" = "Dataverse for Power Apps per app"
"14f8dac2-0784-4daa-9cb2-6d670b088d64" = "Power Apps per app"
"c2da6658-f89d-49f2-9508-40431dee115b" = "CDS Power Apps Per App Custom New"
"70091fc8-1836-470f-a386-f4e6639cb04e" = "Power Apps per app for GCC"
"d7f9c9bc-0a28-4da4-b5f1-731acb27a3e4" = "CDS PowerApps per app plan for GCC"
"2e8dde43-6986-479d-b179-7dbe31c31f60" = "CDS Power Apps Per User Custom"
"ea2cf03b-ac60-46ae-9c1d-eeaeb63cec86" = "Power Apps per User Plan"
"dc789ed8-0170-4b65-a415-eb77d5bb350a" = "Power Automate for Power Apps per User Plan"
"74d93933-6f22-436e-9441-66d205435abb" = "AI Builder capacity Per User add-on"
"8f55b472-f8bf-40a9-be30-e29919d4ddfe" = "Power Apps per User Plan for Government"
"8e3eb3bd-bc99-4221-81b8-8b8bc882e128" = "Power Automate for Power Apps per User Plan for GCC"
"774da41c-a8b3-47c1-8322-b9c1ab68be9f" = "Power Automate (Plan 1) for Government"
"5ce719f1-169f-4021-8a64-7d24dcaec15f" = "PowerApps Plan 1 for Government"
"32ad3a4e-2272-43b4-88d0-80d284258208" = "Common Data Service Power Apps Portals Login Capacity"
"084747ad-b095-4a57-b41f-061d84d69f6f" = "Power Apps Portals Login Capacity Add-On"
"0f7b9a29-7990-44ff-9d05-a76be778f410" = "Common Data Service Power Apps Portals Login Capacity for GCC"
"bea6aef1-f52d-4cce-ae09-bed96c4b1811" = "Power Apps Portals Login Capacity Add-On for Government"
"72c30473-7845-460a-9feb-b58f216e8694" = "CDS PowerApps Portals page view capacity add-on"
"1c5a559a-ec06-4f76-be5b-6a315418495f" = "Power Apps Portals Page View Capacity Add-On"
"352257a9-db78-4217-a29d-8b8d4705b014" = "CDS PowerApps Portals page view capacity add-on for GCC"
"483d5646-7724-46ac-ad71-c78b7f099d8d" = "Power Apps Portals Page View Capacity Add-On for Government"
"c84e52ae-1906-4947-ac4d-6fb3e5bf7c2e" = "Common data service for Flow per business process plan"
"7e017b61-a6e0-4bdc-861a-932846591f6e" = "Flow per business process plan"
"54b61386-c818-4634-8400-61c9e8f6acd3" = "Common Data Service for Power Automate per Business Process Plan for GCC"
"cb83e771-a077-4a73-9201-d955585b29fa" = "Power Automate per Business Process Plan for Government"
"c5002c70-f725-4367-b409-f0eff4fee6c0" = "Flow per user plan"
"769b8bee-2779-4c5a-9456-6f4f8629fd41" = "Power Automate per User Plan for Government"
"3da2fd4c-1bee-4b61-a17f-94c31e5cab93" = "Common Data Service Attended RPA"
"375cd0ad-c407-49fd-866a-0bff4f8a9a4d" = "Power Automate RPA Attended"
"4802707d-47e1-45dc-82c5-b6981f0fb38c" = "Common Data Service Attended RPA for Government"
"fb613c67-1a58-4645-a8df-21e95a37d433" = "Power Automate Attended RPA for Government"
"b475952f-128a-4a44-b82a-0b98a45ca7fb" = "Common Data Service Unattended RPA"
"0d373a98-a27a-426f-8993-f9a425ae99c5" = "Power Automate Unattended RPA add-on"
"5141c408-df3d-456a-9878-a65119b0a750" = "Common Data Service Unattended RPA for Government"
"45e63e9f-6dd9-41fd-bd41-93bfa008c537" = "Power Automate Unattended RPA for Government"
"fc0a60aa-feee-4746-a0e3-aecfe81a38dd" = "Microsoft Power BI Information Services Plan 1"
"2125cfd7-2110-4567-83c4-c1cd5275163d" = "Microsoft Power BI Reporting and Analytics Plan 1"
"9da49a6d-707a-48a1-b44a-53dcde5267f8" = "Power BI Premium P"
"30df3dbd-5bf6-4d74-9417-cccc096595e4" = "Power BI Premium P1 for GCC"
"0bf3c642-7bb5-4ccc-884e-59d09df0266c" = "Power BI Premium Per User"
"32d15238-9a8c-46da-af3f-21fc5351d365" = "Power BI Premium Per User for Government"
"7aae746a-3463-4737-b295-3c1a16c31438" = "Dataverse for Power Pages Authenticated users per site"
"967d9574-a076-4bb7-ab89-f41f64bc142e" = "Power Pages Authenticated Users per site monthly capacity China"
"0d3366f3-266e-4117-b422-7cabbc165e7c" = "Power Pages Authenticated Users per site monthly capacity"
"18e74ca2-b5f0-4802-9a8b-00d2ff1e8322" = "Power Pages Authenticated Users per site monthly capacity GCCH"
"cdf787bd-1546-48d2-9e93-b21f9ea7067a" = "Power Pages Authenticated Users per site monthly capacity GCC"
"03300fea-7a88-45a6-b5bd-29653803c591" = "Power Pages Authenticated Users per site monthly capacity DoD"
"5410f688-68f2-47a5-9b8f-7466194a806a" = "Power Pages Authenticated Users per site mthly capacity GCCH New"
"6817d093-2d30-4249-8bd6-774f01efa78c" = "Power Pages vTrial for Makers"
"0a0a23fa-fea1-4195-bb89-b4789cb12f7f" = "Common Data Service for Virtual Agent Base"
"4b81a949-69a1-4409-ad34-9791a6ec88aa" = "Power Automate for Virtual Agent"
"f6934f16-83d3-4f3b-ad27-c6e9c187b260" = "Virtual Agent Base"
"e4d0b25d-e440-4ee9-aac4-1d5a5db9f3ef" = "Dataverse for Virtual Agent Base for GCC"
"f9f6db16-ace6-4838-b11c-892ee75e810a" = "Power Automate for Virtual Agent for GCC"
"e425b9f6-1543-45a0-8efb-f8fdaf18cba1" = "Virtual Agent Base for GCC"
"cb867b3c-7f38-4d0d-99ce-e29cd69812c8" = "Common Data Service"
"82f141c9-2e87-4f43-8cb2-12d2701dc6b3" = "Power Automate for Virtual Agent"
"1263586c-59a4-4ad0-85e1-d50bc7149501" = "Virtual Agent"
"95df1203-fee7-4726-b7e1-8037a8e899eb" = "Dataverse for Virtual Agent USL for GCC"
"0b939472-1861-45f1-ab6d-208f359c05cd" = "Flow for Virtual Agent for GCC"
"0bdd5466-65c3-470a-9fa6-f679b48286b0" = "Power Virtual Agent USL for GCC"
"cf7034ed-348f-42eb-8bbd-dddeea43ee81" = "Common Data Service for CCI Bots"
"5d798708-6473-48ad-9776-3acc301c40af" = "Flow for CCI Bots"
"f281fb1f-99a7-46ab-9edb-ffd74e260ed3" = "Priva - Risk"
"ebb17a6e-6002-4f65-acb0-d386480cebc1" = "Priva - Risk (Exchange)"
"5b96ffc4-3853-4cf4-af50-e38505080f6b" = "Data Classification in Microsoft 365 - Company Level"
"93d24177-c2c3-408a-821d-3d25dfa66e7a" = "Privacy Management - Subject Rights Request (1)"
"07a4098c-3f2d-427f-bfe2-5889ed75dd7b" = "Privacy Management - Subject Rights Request (1 - Exchange)"
"f0241705-7b44-4401-a6b6-7055062b5b03" = "Privacy Management - Subject Rights Request (10 - Exchange)"
"74853901-d7a9-428e-895d-f4c8687a9f0b" = "Privacy Management - Subject Rights Request (10)"
"8bbd1fea-6dc6-4aef-8abc-79af22d746e4" = "Privacy Management - Subject Rights Request"
"7ca7f875-98db-4458-ab1b-47503826dd73" = "Privacy Management - Subject Rights Request (Exchange)"
"5c221cec-2c39-435b-a1e2-7cdd7fac5913" = "Privacy Management - Subject Rights Request (100 - Exchange)"
"500f440d-167e-4030-a3a7-8cd35421fbd8" = "Privacy Management - Subject Rights Request (100)"
"a6f677b3-62a6-4644-93e7-2a85d240845e" = "COMMON DATA SERVICE FOR PROJECT P1"
"00283e6b-2bd8-440f-a2d5-87358e4c89a1" = "POWER AUTOMATE FOR PROJECT P1"
"4a12c688-56c6-461a-87b1-30d6f32136f9" = "PROJECT P1"
"50554c47-71d9-49fd-bc54-42a2765c555c" = "Common Data Service for Project"
"fa200448-008c-4acb-abd4-ea106ed2199d" = "Flow for Project"
"818523f5-016b-4355-9be8-ed6944946ea7" = "Project P3"
"664a2fed-6c7a-468e-af35-d61740f0ec90" = "Project Online Service for Education"
"22572403-045f-432b-a660-af949c0a77b5" = "Project P3 for Faculty"
"986d454b-9027-4d9f-880b-f1b68f920cc4" = "Microsoft Teams Audio Conferencing with dial-out to select geographies for GCC"
"7a39d7dd-e456-4e09-842a-0204ee08187b" = "Rights Management Adhoc"
"a5f38206-2f48-4d83-9957-525f4e75e9c0" = "IoT Intelligence Add-in Additional Machines"
"83dd9619-c7d5-44da-9250-dc4ee79fff7e" = "Iot Intelligence Add-in for D365 Supply Chain Management"
"3069d530-e41b-421c-ad59-fb1001a23e11" = "Common Data Service for SharePoint Syntex"
"f00bd55e-1633-416e-97c0-03684e42bc42" = "SharePoint Syntex"
"fd2e7f90-1010-487e-a11b-d2b1ae9651fc" = "SharePoint Syntex - SPO type"
"5a10155d-f5c1-411a-a8ec-e99aae125390" = "DOMESTIC AND INTERNATIONAL CALLING PLAN"
"6b340437-d6f9-4dc5-8cc2-99163f7f83d6" = "MCOPSTN3"
"cb22fbd7-ed7d-4786-a27a-e4cd617b69c0" = "Teams Phone Mobile"
"acbca54f-c771-423b-a476-6d7a98cbbcec" = "Microsoft Mesh"
"bdaa59a3-74fd-4137-981a-31d4f84eb8a0" = "Meeting Room Managed Services"
"7861360b-dc3b-4eba-a3fc-0d323a035746" = "AUSTRALIA CALLING PLAN"
"da792a53-cbc0-4184-a10d-e544dd34b3c1" = "OneDrive for business Basic"
"2bdbaf8f-738f-4ac7-9234-3c3ee2ce7d0f" = "Visio web app"
"663a804f-1c30-4ff0-9915-9db84f0d1cea" = "Visio Desktop App"
"98709c2e-96b5-4244-95f5-a0ebe139fb8a" = "ONEDRIVE FOR BUSINESS BASIC FOR GOVERNMENT"
"f85945f4-7a55-4009-bc39-6a5f14a8eac1" = "VISIO DESKTOP APP FOR Government"
"8a9ecb07-cfc0-48ab-866c-f83c4d911576" = "VISIO WEB APP FOR GOVERNMENT"
"59231cdf-b40d-4534-a93e-14d0cd31d27e" = "Dataverse for PAD"
"2d589a15-b171-4e61-9b5f-31d15eeb2872" = "PAD for Windows"
"3b98b912-1720-4a1e-9630-c9a41dbb61d8" = "Windows 365 Business 1 vCPU 2 GB 64 GB"
"1a13832e-cd79-497d-be76-24186f55c8b0" = "Windows 365 Business 2 vCPU 4 GB 128 GB"
"a0b1c075-51c9-4a42-b34c-308f3993bb7e" = "Windows 365 Business 2 vCPU 4 GB 256 GB"
"a790cd6e-a153-4461-83c7-e127037830b6" = "Windows 365 Business 2 vCPU 4 GB 64 GB"
"9d2eed2c-b0c0-4a89-940c-bc303444a41b" = "Windows 365 Business 2 vCPU, 8 GB, 128 GB"
"1a3ef005-2ef6-434b-8be1-faa56c892854" = "Windows 365 Business 2 vCPU 8 GB 256 GB"
"1d4f75d3-a19b-49aa-88cb-f1ea1690b550" = "Windows 365 Business 4 vCPU 16 GB 128 GB"
"30f6e561-8805-41d0-80ce-f82698b72d7d" = "Windows 365 Business 4 vCPU 16 GB 256 GB"
"15499661-b229-4a1f-b0f9-bd5832ef7b3e" = "Windows 365 Business 4 vCPU 16 GB 512 GB"
"648005fc-b330-4bd9-8af6-771f28958ac0" = "Windows 365 Business 8 vCPU 32 GB 128 GB"
"d7a5113a-0276-4dc2-94f8-ca9f2c5ae078" = "Windows 365 Business 8 vCPU 32 GB 256 GB"
"4229a0b4-7f34-4835-b068-6dc8d10be57c" = "Windows 365 Business 8 vCPU 32 GB 512 GB"
"86d70dbb-d4c6-4662-ba17-3014204cbb28" = "Windows 365 Enterprise 1 vCPU 2 GB 64 GB"
"23a25099-1b2f-4e07-84bd-b84606109438" = "Windows 365 Enterprise 2 vCPU 4 GB 64 GB"
"545e3611-3af8-49a5-9a0a-b7867968f4b0" = "Windows 365 Enterprise 2 vCPU 4 GB 128 GB"
"0d143570-9b92-4f57-adb5-e4efcd23b3bb" = "Windows 365 Enterprise 2 vCPU 4 GB 256 GB"
"3efff3fe-528a-4fc5-b1ba-845802cc764f" = "Windows 365 Enterprise 2 vCPU 8 GB 128 GB"
"d3468c8c-3545-4f44-a32f-b465934d2498" = "Windows 365 Enterprise 2 vCPU 8 GB 256 GB"
"2de9c682-ca3f-4f2b-b360-dfc4775db133" = "Windows 365 Enterprise 4 vCPU 16 GB 128 GB"
"9ecf691d-8b82-46cb-b254-cd061b2c02fb" = "Windows 365 Enterprise 4 vCPU 16 GB 256 GB"
"3bba9856-7cf2-4396-904a-00de74fba3a4" = "Windows 365 Enterprise 4 vCPU 16 GB 512 GB"
"2f3cdb12-bcde-4e37-8529-e9e09ec09e23" = "Windows 365 Enterprise 8 vCPU 32 GB 128 GB"
"69dc175c-dcff-4757-8389-d19e76acb45d" = "Windows 365 Enterprise 8 vCPU 32 GB 256 GB"
"0e837228-8250-4047-8a80-d4a34ba11658" = "Windows 365 Enterprise 8 vCPU 32 GB 512 GB"
"64981bdb-a5a6-4a22-869f-a9455366d5bc" = "Windows 365 Shared Use 2 vCPU 4 GB 64 GB"
"51855c77-4d2e-4736-be67-6dca605f2b57" = "Windows 365 Shared Use 2 vCPU 4 GB 128 GB"
"aa8fbe7b-695c-4c05-8d45-d1dddf6f7616" = "Windows 365 Shared Use 2 vCPU 4 GB 256 GB"
"057efbfe-a95d-4263-acb0-12b4a31fed8d" = "Windows 365 Shared Use 2 vCPU 8 GB 128 GB"
"50ef7026-6174-40ba-bff7-f0e4fcddbf65" = "Windows 365 Shared Use 2 vCPU 8 GB 256 GB"
"dd3801e2-4aa1-4b16-a44b-243e55497584" = "Windows 365 Shared Use 4 vCPU 16 GB 128 GB"
"2d1d344e-d10c-41bb-953b-b3a47521dca0" = "Windows 365 Shared Use 4 vCPU 16 GB 256 GB"
"48b82071-99a5-4214-b493-406a637bd68d" = "Windows 365 Shared Use 4 vCPU 16 GB 512 GB"
"e4dee41f-a5c5-457d-b7d3-c309986fdbb2" = "Windows 365 Shared Use 8 vCPU 32 GB 128 GB"
"1e2321a0-f81c-4d43-a0d5-9895125706b8" = "Windows 365 Shared Use 8 vCPU 32 GB 256 GB"
"fa0b4021-0f60-4d95-bf68-95036285282a" = "Windows 365 Shared Use 8 vCPU 32 GB 512 GB"
"aaa2cd24-5519-450f-a1a0-160750710ca1" = "Windows Store for Business EDU Store_faculty"
"f477b0f0-3bb1-4890-940c-40fcee6ce05f" = "Microsoft Workplace Analytics"
"84c289f0-efcb-486f-8581-07f44fc9efad" = "Azure Active Directory workload identities P1"
"7dc0e92d-bf15-401d-907e-0884efe7c760" = "Azure Active Directory workload identities P2"
}

# BEGIN LICENSE UTILIZATION REPORT

# Initialize license report array.
$LicensesReport = @()

# Initialize conditional text array.
$conditionalText = @()

# Initialize all start row and start column values.
$licenseNameStartRow = $SubscribedSKUs.value.Count + 3
$servicePlansStartRow = $SubscribedSKUs.value.Count + 4
$servicePlansStartColumn = 1
$licenseAssignmentsStartColumn = 1

# Add conditional formating for overassigned licenses.
$conditionalText += New-ConditionalText -Text "OVERASSIGNED" -ConditionalTextColor White -BackgroundColor Black

# Assemble the license utilization report.
foreach($sku in $SubscribedSKUs.value){

    # Store the GUID of the current subscribed SKU in a variable.
    $skuGUID = $sku.skuId
    
    # Check if owned license count is 0, if not then calulate license utilization.
    if($sku.prepaidUnits.enabled -EQ 0){
    
        # Check if assigned count exceeds owned count when owned count is 0, if yes write license utilization as OVERASSIGNED, if no write license utilization as N/A.
        switch($sku.consumedUnits){
        
            {$_ -GT 0}{$licenseUtilization = "OVERASSIGNED"}
            {$_ -EQ 0}{$licenseUtilization = "N/A"}
        }
    }
    
    # Calculate license utilization.
    else{

        # Check if license utilization rate is 100%, if yes write as string value of "100%", if no calculate actual percentage.
        switch(($sku.consumedUnits/$sku.prepaidUnits.enabled) -Match "."){
        
            "False"{

                $licenseUtilization = "100%"
            }
            
            "True"{
            
                $licenseUtilization = ($sku.consumedUnits/$sku.prepaidUnits.enabled).ToString("P")
            }
        }
    }

    # Add conditional text for license utilization.
    if($licenseUtilization -NotIn ($conditionalText.Text, "OVERASSIGNED", "N/A")){
        
        switch([int]($licenseUtilization.Trim("%"))){
            
            # Action taken if license utilization is GT 90%.
            {$_ -GT 90}{
                
                $conditionalText += New-ConditionalText -Text $licenseUtilization -ConditionalTextColor Black -BackgroundColor Red
            }

            # Action taken if license utilization is LE 90% and GT 70%.
            {($_ -LE 90) -and ($_ -GT 70)}{
                
                $conditionalText += New-ConditionalText -Text $licenseUtilization -ConditionalTextColor Black -BackgroundColor Yellow
            }

            # Action taken if license utilization is LE 70%.
            {$_ -LE 70}{
                
                $conditionalText += New-ConditionalText -Text $licenseUtilization -ConditionalTextColor Black -BackgroundColor Lime
            }
        }
    }

    # Attempt to fetch the license name from the hashtable, if not then use the SKU part number.
    try{
    
        $licenseName = $LicensesHashTable.Item($sku.skuId)
    }

    catch{
    
        $licenseName = $sku.skuPartNumber
    }
    
    # Add info for current license to the license report array.
    $LicensesReport += [PSCustomObject]@{
    
        LicenseSkuId = $sku.skuId
        LicenseName = $licenseName
        ConsumedUnits = $sku.consumedUnits
        TotalUnits = $sku.prepaidUnits.enabled
        LicenseUtilization = $licenseUtilization
    }

    # Destroy license utilization variable.
    Remove-Variable licenseUtilization    
}

# Export the license utilization report to Excel.
$LicensesReport | Sort LicenseName | Export-Excel -Path $ReportPath -WorksheetName LicenseAssignmentAndOwnership -ConditionalText $conditionalText -TableStyle Medium12 -AutoSize

# Destroy conditional text variable.
Remove-Variable conditionalText

# END LICENSE UTILIZATION REPORT.

# BEGIN BASIC LICENSE ASSIGNMENT REPORT

# Initialize licensed users basic array.
$LicensedUsersBasicArray = @()

# Initialize conditional text array.
$conditionalText = @()

# Add conditional text for user state.
$conditionalText += New-ConditionalText -ConditionalType Equal -Text "Enabled" -ConditionalTextColor Black -BackgroundColor Lime
$conditionalText += New-ConditionalText -ConditionalType Equal -Text "Disabled" -ConditionalTextColor White -BackgroundColor Red

# Collect all users with at least 1 active license assignment and set skipToken if it's present.
$allLicensedUsersBasic = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/beta/users?filter=assignedLicenses/$count ne 0&$count=true&consistencyLevel=eventual&select=displayName,userPrincipalName,assignedLicenses,accountEnabled,onPremisesLastSyncDateTime'
$skipToken = ($allLicensedUsersBasic.'@odata.nextLink' -Split "skipToken=")[1]

# Check for paged users, add to all license users array if paged users exist.
if($allLicensedUsersBasic.'@odata.nextLink'){

    $skipToken = ($allLicensedUsersBasic.'@odata.nextLink' -Split "skipToken=")[1]
    
    do{
    
        $allLicensedUsersBasicPageURI = 'https://graph.microsoft.com/beta/users?filter=assignedLicenses/$count ne 0&$count=true&consistencyLevel=eventual&select=displayName,userPrincipalName,assignedLicenses,accountEnabled,onPremisesLastSyncDateTime&skiptoken=' + "$skipToken"
        $allLicensedUsersBasicPage = Invoke-MgGraphRequest -Method GET -Uri $allLicensedUsersBasicPageURI
        $allLicensedUsersBasic.value += $allLicensedUsersBasicPage.value
        $skipToken = ($allLicensedUsersBasicPage.'@odata.nextLink' -Split "skipToken=")[1]
    } until (!$allLicensedUsersBasicPage.'@odata.nextLink')
}

# Assemble the basic user license assignment report.
foreach($userBasic in $allLicensedUsersBasic.value){

    $LicensedUserBasicObject = [PSCustomObject]@{}

    switch($userBasic.accountEnabled){
    
        "True"{
        
            $LicensedUserBasicObject | Add-Member -MemberType NoteProperty -Name UserState -Value "Enabled"
        }

        "False"{
        
            $LicensedUserBasicObject | Add-Member -MemberType NoteProperty -Name UserState -Value "Disabled"
        }
    }

    $LicensedUserBasicObject | Add-Member -MemberType NoteProperty -Name LastSyncTime -Value $userBasic.onPremisesLastSyncDateTime
    $LicensedUserBasicObject | Add-Member -MemberType NoteProperty -Name UserDisplayName -Value $userBasic.displayName
    $LicensedUserBasicObject | Add-Member -MemberType NoteProperty -Name UserPrincipalName -Value $userBasic.userPrincipalName

    $userBasicLicenses = ""

    foreach($userBasicLicense in $userBasic.assignedLicenses.skuId){
    
        $userBasicLicenseName = $LicensesHashTable.Item($userBasicLicense) + ", "
        $userBasicLicenses += $userBasicLicenseName
    }

    $LicensedUserBasicObject | Add-Member -MemberType NoteProperty -Name UserLicenses -Value $userBasicLicenses.Remove($userBasicLicenses.LastIndexOf(", "))

    $LicensedUsersBasicArray += $LicensedUserBasicObject

}

# Export the basic user license assignment report to Excel.
$LicensedUsersBasicArray | Sort UserDisplayName | Export-Excel -Path $ReportPath -WorksheetName UserLicenseAssignmentsBasic -ConditionalText $conditionalText -TableStyle Medium12 -AutoSize

# Destroy conditional text variable.
Remove-Variable conditionalText

# END BASIC LICENSE ASSIGNMENT REPORT

# BEGIN ADVANCED LICENSE ASSIGNMENT REPORT

# Initialize licensed users advanced array.
$LicensedUsersAdvancedArray = @()

# Initialize conditional text array.
$conditionalText = @()

# Add conditional text for assigned and unassigned licenses.
$conditionalText += New-ConditionalText -ConditionalType Equal -Text "Y" -ConditionalTextColor Black -BackgroundColor Lime
$conditionalText += New-ConditionalText -ConditionalType Equal -Text "N" -ConditionalTextColor White -BackgroundColor Red

# Collect all users with at least 1 active license assignment and set skipToken if it's present.
$allLicensedUsersAdvanced = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/beta/users?filter=assignedLicenses/$count ne 0&$count=true&consistencyLevel=eventual&select=displayName,userPrincipalName,assignedLicenses,accountEnabled'

# Check for paged users, add to all license users array if paged users exist.
if($allLicensedUsersAdvanced.'@odata.nextLink'){

    $skipToken = ($allLicensedUsersAdvanced.'@odata.nextLink' -Split "skipToken=")[1]
    
    do{
    
        $allLicensedUsersAdvancedPageURI = 'https://graph.microsoft.com/beta/users?filter=assignedLicenses/$count ne 0&$count=true&consistencyLevel=eventual&select=displayName,userPrincipalName,assignedLicenses&skiptoken=' + "$skipToken"
        $allLicensedUsersAdvancedPage = Invoke-MgGraphRequest -Method GET -Uri $allLicensedUsersAdvancedPageURI
        $allLicensedUsersAdvanced.value += $allLicensedUsersAdvancedPage.value
        $skipToken = ($allLicensedUsersAdvancedPage.'@odata.nextLink' -Split "skipToken=")[1]
    } until (!$allLicensedUsersAdvancedPage.'@odata.nextLink')
}

# Assemble the advanced user license assignment report.
foreach($userAdvanced in $allLicensedUsersAdvanced.value){

    # Format user display name and email as one string.
    $userNameAndEmail = $userAdvanced.displayName + " (" + $userAdvanced.userPrincipalName + ")"

    # Initialize the user object as a PSCustomObject.
    $LicensedUserAdvancedObject = [PSCustomObject]@{

        User = $userNameAndEmail
    }

    # Add each license to the user object with it's assignment status.
    foreach($sku in $SubscribedSKUs.value){

        if($sku.skuId -In $userAdvanced.assignedLicenses.skuId){

            # Add license assignment status as assigned for the current license.
            $LicensedUserAdvancedObject | Add-Member -MemberType NoteProperty -Name $LicensesHashTable.Item($sku.skuId) -Value "Y"
        }

        else{

            # Add license assignment status as not assigned for the current license.
            $LicensedUserAdvancedObject | Add-Member -MemberType NoteProperty -Name $LicensesHashTable.Item($sku.skuId) -Value "N"
        }
    }

    # Add user object to the user assignments report.
    $LicensedUsersAdvancedArray += $LicensedUserAdvancedObject
}

# Export the advanced user license assignment report to Excel.
$LicensedUsersAdvancedArray | Sort User | Export-Excel -Path $ReportPath -WorksheetName UserLicenseAssignmentsAdvanced -ConditionalText $conditionalText -TableStyle Medium12 -AutoSize

# Destroy conditional text variable.
Remove-Variable conditionalText

# END ADVANCED LICENSE ASSIGNMENT REPORT

# BEGIN SERVICE PLANS REPORT

# Assemble the service plans report.
foreach($sku in $SubscribedSKUs.value){
    
    # Initialize service plans array for the current license.
    $servicePlans = @()

    #Assemble service plans array for the current license.
    foreach($servicePlan in $sku.servicePlans){

        # Add each service plan for the current license.
        $servicePlans += [PSCustomObject]@{
        
            servicePlanId = $servicePlan.servicePlanId
            servicePlanName = $servicePlan.servicePlanName
            servicePlanFriendlyName = $ServicePlansHashTable.Item($servicePlan.servicePlanId)
        }
    }

    # Export service plans for current license to Excel.
    "(" + $LicensesHashTable.Item($sku.skuId) + ") Service Plans" | Export-Excel -Path $ReportPath -WorksheetName ServicePlansOverview -StartRow 1 -StartColumn $servicePlansStartColumn -AutoSize
    $servicePlans | Export-Excel -Path $ReportPath -WorksheetName ServicePlansOverview -StartRow 3 -StartColumn $servicePlansStartColumn -AutoSize

    # Increase service plans start column by 4.
    $servicePlansStartColumn += 4
}

# END SERVICE PLANS REPORT

# END SCRIPT