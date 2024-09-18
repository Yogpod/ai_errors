# AI Errors Reporter

AI Errors Reporter is a Lua-based error reporting tool that utilizes AI to diagnose and suggest fixes for code errors. The tool is designed to use errors in gmod and captures stack traces for deeper analysis. It reports these errors and fixes from chatGPT to a specified Discord webhook.

## Features

- **Error Reporting**: Automatically captures and reports errors that occur within designated realms in a game or server.
- **User-friendly Diagnosis**: Integrates with AI to provide concise diagnostic messages and suggested fixes for the errors reported.
- **Repetitive Error Detection**: Monitors players for repetitive error reporting, suppressing further reports after a specified threshold.
- **Contextual Error Lines**: Captures relevant lines of code around the error and sends it to the AI for analysis.
- **Discord Integration**: Sends a formatted error analysis report to a specified Discord channel via webhook.

## Getting Started

To integrate the AI Errors Reporter into your project, follow these steps:

### Prerequisites

- Garry's Mod Server
- Access to a Discord webhook (you can create your own in Discord settings)

### Installation

1. **Clone the Repository** (if applicable):
   ```bash
   git clone https://github.com/Yogpod/ai_errors
   cd ai_errors
   ```

2. **Add the Code to Your Project**:
   Copy the code provided into your addons folder. Ensure that [reqwest](https://github.com/WilliamVenner/gmsv_reqwest) or [chttp](https://github.com/timschumi/gmod-chttp) is within lua/bin if you care about discord messages.

3. **Set Up Discord Webhook**:
   In the `ai_errors/server/sv_config.lua` folder, set your Discord webhook URL:
   ```lua
   ai_errors.webhook = "YOUR_DISCORD_WEBHOOK_URL"
   ```
   This is also available in the GUI, opened by command `ai_errors_config` shown below.
![gmod_Nn1QPmJxeo](https://github.com/user-attachments/assets/198399bd-025b-4de3-b753-c27c879a82b7)

4. **Set Up API Key**:
   In the `ai_errors/server/sv_config.lua` folder, set your API key:
   ```lua
   ai_errors.apikey = "YOUR_AI_API_KEY"
   ```
   This is also available in the GUI, opened by command `ai_errors_config` shown above.
   [OpenAI API Key Help](https://help.openai.com/en/articles/4936850-where-do-i-find-my-openai-api-key)

   You can also use anthropic's claude, just set a claude API key in the config file.
   [Claude API Key Help](https://console.anthropic.com/settings/keys)

## Usage

When errors occur, they are automatically reported using the `ai_errors.reportError` function. This function will handle:

- Reporting errors only once.
- Counting repetitive errors per player.
- Fetching relevant code context around the error for better diagnosis.
- Sending a formatted report to the configured Discord channel.

You can customize the number of repeated errors before suppression by modifying the threshold in the provided code.

### Example Error Handling

When an error is reported, the following data is formatted and sent to Discord:

- Error message and realm.
- Player information if applicable.
- Relevant lines of code surrounding the error.

<img src="https://github.com/user-attachments/assets/c82d8365-2796-402b-a055-1a932a0cd0f2" alt="1" width="250"/>
<img src="https://github.com/user-attachments/assets/52e57434-02d9-4266-a5c7-934f5bc04767" alt="2" width="250"/>
<img src="https://github.com/user-attachments/assets/d6809878-8370-4ec7-95e5-29b95f37e998" alt="3" width="250"/>

## Contributing

Contributions are welcome! Please feel free to submit a pull request or report issues.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Acknowledgments

- Thanks to the developers at OpenAI for the AI models used in this project.
- Thanks to the developers at Anthropic for the AI models used in this project.
- Thanks to the Discord team for providing webhook support.

## Contact

For any questions or feedback, feel free to create an issue.
