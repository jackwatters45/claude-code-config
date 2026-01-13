---
name: visual-feedback
description: This skill should be used when building frontend UIs, verifying layout changes, checking responsive design, testing dark/light mode, taking screenshots of the browser, or when the user asks to "check the UI", "verify the layout", "take a screenshot", or "test how it looks".
---

# Visual Feedback for Frontend Development

Use browser automation to verify UI changes visually rather than relying solely on code inspection.

## When to Use Visual Feedback

- After CSS or layout changes
- When implementing responsive designs
- When adding dark/light mode support
- To verify component rendering
- When debugging visual issues the user describes

## Available Tools

Two MCP toolsets provide browser access:

### Chrome DevTools MCP (via Chrome Extension)
- `mcp__chrome-devtools__take_screenshot` - Capture viewport or full page
- `mcp__chrome-devtools__take_snapshot` - Get accessibility tree (text-based page structure)
- `mcp__chrome-devtools__emulate` - Test color schemes, network throttling, geolocation
- `mcp__chrome-devtools__navigate_page` - Navigate to URLs
- `mcp__chrome-devtools__click`, `fill`, `hover` - Interact with elements

### Playwriter MCP
- `mcp__playwriter__execute` - Run Playwright code snippets for complex automation
- Supports `screenshotWithAccessibilityLabels({ page })` for visual element identification

## Connection Methods

### Option 1: Chrome Extension (Recommended)
The user clicks the Playwriter/Chrome DevTools extension icon on the tab to control. No additional setup required.

### Option 2: Remote Debugging
If the extension is unavailable, launch Chrome with remote debugging:
```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
```

## Common Workflows

### Verify a Layout Change
1. Take a screenshot of the current state
2. Analyze the visual output
3. Report any issues or confirm it looks correct

### Test Dark Mode
```
mcp__chrome-devtools__emulate with:
- colorScheme: "dark" or "light"
```
Then take a screenshot to verify.

### Check Responsive Design
```
mcp__chrome-devtools__resize_page with width/height
```
Then take a screenshot at each breakpoint.

### Debug Visual Issues
1. Take an accessibility snapshot to understand page structure
2. Take a screenshot to see the visual output
3. Compare expected vs actual appearance

## Best Practices

- Take screenshots after significant UI changes to confirm correctness
- Use accessibility snapshots for understanding page structure without images
- Emulate different conditions (dark mode, slow network) to test edge cases
- When reporting issues, describe what was expected vs what was observed
