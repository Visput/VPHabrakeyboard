## Habrakeyboard
Habrakeyboard is a native iOS keyboard extension that is suitable for using in pair with [Habrahabr app](https://itunes.apple.com/us/app/habrahabr/id778613673?mt=8). The main scenario of usage is writing comments to articles.

Full description of project is available [here (RUS)](http://habrahabr.ru/post/235917/)

### Demonstration
<img src="http://hsto.org/files/b60/a86/999/b60a86999e7a471e9b4b9819a40572d1.gif"/>

### Installation
Run VPHabrakeyboardApp.xcodeproj on device or similuator. After that go to Device Settings -> General -> Keyboard -> Keyboards -> Add New Keyboard -> Choose "Хабр".
If you need integrate this extension to your app, create new target for Custom Keyboard and copy contents of VPHabrakeyboard/Keyboard directory to your project.

### Known Issues
Keyboard settings (available in global device settings) can't be saved. No any changes can be applied. It's iOS8 bug.
