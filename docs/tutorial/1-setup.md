# 1. Project Setup

Welcome to the Pico Tutorial! To help you understand the power of Pico without overwhelming you, we are going to use an **agile approach** to build a complete Todo application. 

We will break the application into four tiny, digestible steps.

## The Goal
By the end of this tutorial, you will have a functional Todo app where users can:
- View a list of tasks.
- Add new tasks.
- Toggle task completion.
- See a count of incomplete tasks.

All while maintaining **zero boilerplate** and ensuring high performance using Pico's surgical rebuilds.

## Installation

First, create a new Flutter project and install the `pico` package:

```bash
flutter create pico_todo
cd pico_todo
flutter pub add pico
```

You're ready to go! Let's move on to the most important part: defining our state.
