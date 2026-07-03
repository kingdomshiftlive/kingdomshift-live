# dSYM Upload Fix for DeepAR and ZegoExpressEngine

This script fixes the missing dSYM files error when uploading to App Store Connect.

## Problem
App Store Connect requires dSYM files for all frameworks, including third-party ones like DeepAR and ZegoExpressEngine. These frameworks come as xcframeworks and their dSYMs need to be extracted and included in the archive.

## Solution
The `copy_dsyms.sh` script automatically extracts and includes dSYM files from these frameworks during the archive process.

## How to Add the Script to Xcode

1. Open your project in Xcode: `ios/Runner.xcworkspace`

2. Select the **Runner** target in the project navigator

3. Go to **Build Phases** tab

4. Click the **+** button and select **New Run Script Phase**

5. Name it: **"Copy dSYMs for Third-Party Frameworks"**

6. Drag it to be **after** "Embed Frameworks" and **before** "Upload Symbols" (if present)

7. In the script box, paste:
   ```bash
   "${SRCROOT}/scripts/copy_dsyms.sh"
   ```

8. Make sure:
   - ✅ **Shell**: `/bin/sh`
   - ✅ **Show environment variables in build log**: Unchecked (optional)
   - ✅ **Run script only when installing**: Unchecked
   - ✅ **For install builds only**: Unchecked

9. Save and rebuild your archive

## Verification

After archiving, you can verify the dSYMs are included:

1. Right-click on your `.xcarchive` file
2. Select "Show Package Contents"
3. Navigate to `dSYMs/`
4. You should see:
   - `DeepAR.framework.dSYM`
   - `ZegoExpressEngine.framework.dSYM`
   - `Runner.app.dSYM`

## Troubleshooting

If dSYMs are still missing:

1. Check the build log for script output (look for `[Copy dSYMs]` messages)
2. Verify the framework paths are correct
3. Ensure the script has execute permissions: `chmod +x ios/scripts/copy_dsyms.sh`
4. Try cleaning the build folder (Cmd+Shift+K) and rebuilding

## Alternative: Manual dSYM Generation

If the script doesn't work, you can manually generate dSYMs:

```bash
# For DeepAR
dsymutil /path/to/DeepAR.xcframework/ios-arm64/DeepAR.framework/DeepAR -o DeepAR.framework.dSYM

# For ZegoExpressEngine  
dsymutil /path/to/ZegoExpressEngine.xcframework/ios-arm64/ZegoExpressEngine.framework/ZegoExpressEngine -o ZegoExpressEngine.framework.dSYM
```

Then manually add these dSYMs to your archive before uploading.

