# API Key Setup

## 🔐 Secure API Key Configuration

To use the Heartifacts app, you need to configure your OpenAI API key securely.

### Steps:

1. **Copy the example file:**
   ```bash
   cp Heartifacts/Heartifacts/Config.example.plist Heartifacts/Heartifacts/Config.plist
   ```

2. **Edit Config.plist:**
   - Open `Heartifacts/Heartifacts/Config.plist` in Xcode or a text editor
   - Replace `YOUR_API_KEY_HERE` with your actual OpenAI API key
   - Save the file

3. **Verify the setup:**
   - The `Config.plist` file is already in `.gitignore` so it won't be committed
   - Your API key will remain secure and private

### Security Notes:
- ✅ `Config.plist` is in `.gitignore` - your API key won't be pushed to git
- ✅ `Config.example.plist` is safe to commit (contains no real keys)
- ✅ The app will show a warning if the API key is not configured properly

### For Team Members:
- Each developer needs to create their own `Config.plist` file
- Use the `Config.example.plist` as a template
- Never commit `Config.plist` to version control
