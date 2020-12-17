# Spawn belt

Spawn a fully compressed belt of any item, configurable by chest or circuit network.

## With chest

Place a chest behind the spawn belt and it will spawn the item type that was last found in the first slot of the chest

## With circuit network

Connect the spawn belt using a red or green wire and send a signal to it, it will spawn the item with the highest signal count, regardless of green/red color.

## Measure throughput

Placing a chest or a constant combinator behind the void belt will automatically fill it with the contents that the belt cleared in the last second, showing a rough throughput per second.

# Changelog

### 1.0.12

- Added support for Factorio 1.1.x

### 1.0.11

- Updated counting logic of void-belts to take last 10 seconds average
- Small fixes and code cleanup
- Added constant combinators to be automatically set when placed after a void-belt

### 1.0.10

- Recoloured the void-belt to be red
- When placing a chest after a void-belt it will contain the items cleared in the last second
- Removed the default item "iron-ore", when placed spawn belts now do nothing.

### 1.0.9

- Added support for Factorio 1.0.x

### 1.0.8

- Added support for Factorio 0.17.x

### 1.0.7

- Added support for Factorio 0.16.x

### 1.0.6

- Fixed crash when connecting circuit network with no signals
- Fixed crash when deconstructing while globals were not initialized

### 1.0.5

- Support for building by blueprint
- Spawn-belt directly checks for chests when placed infront of one
- Fixed item order

### 1.0.4

- Support for 0.15
- Added item descriptions

### 1.0.3

- Changed factorio version to 0.14

### 1.0.2

- Fixed error caused by scripting change in 0.13.11, this version may not work with older versions of factorio

### 1.0.1

- Fixed a occasional crash when placing a belt after you've removed all others.

### 1.0.0

- Added circuit network listeners for spawn belt and performance improvements

# Contributors

- [Bart Huijgen](https://github.com/barthuijgen)
- [isitLoVe](https://github.com/isitLoVe)
