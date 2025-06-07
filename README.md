# AppRouter 🚀

![AppRouter](https://img.shields.io/badge/AppRouter-SwiftUI-brightgreen)

Welcome to **AppRouter**, a simple yet powerful router designed specifically for SwiftUI applications. This repository provides an easy way to manage navigation in your SwiftUI apps, ensuring a smooth user experience. 

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Example](#example)
- [Contributing](#contributing)
- [License](#license)
- [Releases](#releases)

## Introduction

In modern app development, effective navigation is crucial. **AppRouter** simplifies this process for SwiftUI developers. With its straightforward API, you can easily manage routes and transitions between views.

## Features

- **Lightweight**: Minimal overhead for quick integration.
- **SwiftUI Compatible**: Designed to work seamlessly with SwiftUI.
- **Easy to Use**: Intuitive API for developers of all skill levels.
- **Customizable**: Tailor navigation to fit your app's unique needs.

## Installation

To get started with **AppRouter**, clone the repository and add it to your SwiftUI project.

```bash
git clone https://github.com/Sonupr130/AppRouter.git
```

After cloning, you can add the `AppRouter` files to your project manually or use Swift Package Manager for easier integration.

## Usage

Using **AppRouter** is straightforward. First, import the library into your SwiftUI views:

```swift
import AppRouter
```

Next, set up your routes and manage navigation using the provided API. Here's a simple example:

```swift
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: DetailView()) {
                    Text("Go to Detail View")
                }
            }
        }
    }
}
```

## Example

Here’s a complete example to demonstrate how to use **AppRouter** in your SwiftUI application.

```swift
import SwiftUI
import AppRouter

struct MainView: View {
    var body: some View {
        Router {
            Route(path: "/home") {
                HomeView()
            }
            Route(path: "/details") {
                DetailView()
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home View")
            NavigationLink(destination: DetailView()) {
                Text("Go to Detail")
            }
        }
    }
}

struct DetailView: View {
    var body: some View {
        Text("Detail View")
    }
}
```

This example sets up a basic navigation structure using **AppRouter**. You can easily expand this to include more routes and views as needed.

## Contributing

We welcome contributions to **AppRouter**! If you would like to help improve the project, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/YourFeature`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add some feature'`).
5. Push to the branch (`git push origin feature/YourFeature`).
6. Open a pull request.

Please ensure your code follows the project's style guidelines and includes tests where applicable.

## License

**AppRouter** is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Releases

For the latest updates and downloads, please visit our [Releases section](https://github.com/Sonupr130/AppRouter/releases). Here, you can find the latest version of **AppRouter**. Download and execute the files to get started with your SwiftUI project.

## Conclusion

Thank you for checking out **AppRouter**! We hope this library helps you streamline navigation in your SwiftUI applications. For more information and updates, keep an eye on the [Releases section](https://github.com/Sonupr130/AppRouter/releases). 

Feel free to reach out with any questions or suggestions. Happy coding!