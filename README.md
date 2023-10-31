# King of the Road - Competitive Delivery Job Script for FiveM

A unique delivery job script for FiveM servers that combines elements of racing and role-played delivery jobs, providing players with a competitive delivery experience.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Contribute](#contribute)
- [License](#license)

## Features

- **Competitive Delivery Mechanism**: Players race against time and each other to maximize their rewards.
- **Dynamic Rewards**: Rewards scale based on players' finishing position.
- **Vehicle Restrictions**: Only certain vehicles like trucks or trailers are allowed.
- **Cooldown System**: Once a set number of players take the job, it goes on a cooldown.
- **Visual Indicators**: Checkpoints and blips guide players from start to end.
- **Time Limit**: Players have a set time to complete the delivery.
- **Interactive**: Players can forfeit jobs and view remaining time.

## Installation

1. Clone this repository or download the zip.
2. Extract the folder `king_of_the_road` into your FiveM resources directory.
3. Add `start king_of_the_road` to your server's `server.cfg` file.

## Usage

1. Players can approach the designated starting point (marked with a truck blip on the map) to begin the delivery job.
2. Once the job starts, players must deliver to the specified endpoint within the time limit.
3. Rewards are given based on finishing position and timeliness.

## Configuration

The script can be customized by modifying the `client.lua` and `server.lua` files. Ensure you adjust based on your server setup, VRP version, or any other resources.

## Contribute

Contributions are always welcome! If you have any ideas, just open an issue and tell us what you think. If you'd like to contribute code, open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
