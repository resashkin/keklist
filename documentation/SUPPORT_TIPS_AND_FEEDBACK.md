# Support Tips, Feedback and Emotions Save Implementation

## Overview
The paywall also offers one-time tips. Pro users get a tips-only sheet. Settings can send feedback to the developer's
Telegram, and the emotions sheet shown after saving a mind has a Save button.

## Implementation Details

### 1. Tips (`paywall_bottom_sheet.dart`)
- Consumables `keklist_tip_1`, `keklist_tip_10` and `keklist_tip_100` are loaded with
  `Purchases.getProducts(..., productCategory: ProductCategory.nonSubscription)`.
- `_TipCard` buys at once (`PurchaseParams.storeProduct`) and thanks the user. Until the store returns a product,
  its tile shows the fallback price, dimmed and disabled.
- `PaywallBottomSheet.show(context, tipsOnly: true)` shows only the tips. Settings opens it from "Support keklist",
  which replaces "keklist PRO" for subscribers.
- Pro still gates only the weather source; nothing else is locked.

### 2. Feedback (`telegram_feedback.dart`, `feedback_sheet.dart`)
- Telegram is the only feedback channel: "Email us", "Suggest a feature", "Release notes" (with the What's New page
  shown after updates, and `webview_flutter`) and "Dev Blog" were removed.
- `FeedbackSheet` is a bottom sheet: title and ✕ in the header, a borderless text field without a placeholder that
  grows with the text, and a centered glass Send above the keyboard.
- `TelegramFeedback.send` posts to `sendMessage` of a feedback-only bot. It sends the text, the app version and
  build, and the platform, and only when the user taps Send.
- Keys in `dotenv`: `TELEGRAM_FEEDBACK_BOT_TOKEN`, `TELEGRAM_FEEDBACK_CHAT_ID`. Without them the "Leave feedback"
  row is hidden.
- The token ships inside the app. Anyone who extracts it can send from the bot or read messages sent to it, so the
  bot is used only for this, and its token is revoked with @BotFather if abused.

### 3. Emotions Save
`EmotionMarkingSheet.show(showsSaveButton: true)` adds a wide Save button. The creator uses it in the "after save"
mode; ✕ still saves as before.

## Testing
- Paywall: tips appear under the plans; with sandbox products, a purchase shows the thank-you.
- Add the two keys, open Settings → Leave feedback, send a message.
- Create a mind with text: the emotions sheet shows Save.

## Edge Cases & Considerations
- The products must be created in App Store Connect and Google Play as consumables and added to RevenueCat.
- `dotenv` is bundled at build time, so feedback appears only in builds made after the keys are added.
