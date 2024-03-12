import nimibook

var book = initBookWithToc:
  entry("Introduction", "index.md")
  entry("How to Get Govee API Key", "api-key.md")
  section("Commands", "commands.md"):
    entry("Setup", "commands/setup.md")
    entry("Turn", "commands/turn.md")
    entry("Brightness", "commands/brightness.md")
    entry("Color", "commands/color.md")
    entry("Color Temp", "commands/color-temp.md")
    entry("State", "commands/state.md")
    entry("RGB", "commands/rgb.md")
    entry("Picker", "commands/picker.md")
    entry("Devices", "commands/devices.md")

    # ---

    entry("Version", "commands/version.md")
    entry("About", "commands/about.md")
    entry("Description", "commands/description.md")
    entry("Source", "commands/source.md")
    entry("Repo", "commands/repo.md")
    entry("License", "commands/license.md")
    entry("Docs", "commands/docs.md")

nimibookCli(book)
