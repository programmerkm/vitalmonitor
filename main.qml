import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Extras 1.4
import QtQuick.Window 2.0

import "HeartData.js" as Data

ApplicationWindow {
    id:app
    width: 800
    height: 480
    visible: true
    color: "#000000"
    title: qsTr("Hello World")

    property int frequency: 60
    property int beatDataIndex: -1
    property int heartDataIndex: 0
    property int beatDifference: 1200
    property int respirationRate : 10
    property int heartRate: 80
    property var previousTime: 0
    property string curveColor: "#22ff22"
    property string alarmColor: "#ff2222"
    property string textColor: "#22ff22"
    property string gridColor: "#333333"
    property string respirationColor: "#33ffff"

    function pulse()
    {
        if (!heartAnimation.running)
        {
            heartAnimation.restart()
            heartTimer.restart()
            calculateFrequency();
            app.beatDataIndex = 0
            heartRate = getRandomInt(70,120)
        }

        if(!lungstAnimation.running)
        {
            lungstAnimation.restart()
            app.respirationRate = getRandomInt(15,25)
        }
    }

    function calculateFrequency() {
        var ms = new Date().getTime();
        if (app.previousTime > 0)
            app.beatDifference = 0.8*beatDifference + 0.2*(ms - app.previousTime)
        app.frequency = Math.round(60000.0 / app.beatDifference)
        app.previousTime = ms;
    }

    function updateData() {
        app.heartDataIndex++;
        if (app.heartDataIndex >= Data.heartData.length)
            app.heartDataIndex = 0;
        else
            app.heartDataIndex++;

        if (beatDataIndex >= 0)
            fillBeatData()
        else
            fillRandomData()

        heartCanvas.requestPaint()
    }

    function getRandomInt(min, max)
    {
      min = Math.ceil(min);
      max = Math.floor(max);
      return Math.floor(Math.random() * (max - min) + min); //The maximum is exclusive and the minimum is inclusive
    }


    function fillBeatData() {
        var value = 0;
        switch (app.beatDataIndex) {
        case 0: value = Math.random()*0.1+0.1; break;
        case 1: value = Math.random()*0.1+0.0; break;
        case 2: value = Math.random()*0.3+0.7; break;
        case 3: value = Math.random()*0.1-0.05; break;
        case 4: value = Math.random()*0.3-0.8; break;
        case 5: value = Math.random()*0.1-0.05; break;
        case 6: value = Math.random()*0.1-0.05; break;
        case 7: value = Math.random()*0.1+0.15; break;
        default: value = 0; break;
        }

        Data.heartData[app.heartDataIndex] = value;
        app.beatDataIndex++;
        if (app.beatDataIndex > 7)
            app.beatDataIndex = -1
    }

    function fillRandomData() {
        Data.heartData[app.heartDataIndex] = Math.random()*0.50-0.025
    }


    onWidthChanged:
    {
        Data.fillHeartData(Math.floor(app.width*0.5))
        gridCanvas.requestPaint();
    }

    onHeightChanged: gridCanvas.requestPaint()

    Item {
        id: grid
        anchors.fill: parent

        Canvas {
            id: gridCanvas
            anchors.fill: parent
            antialiasing: true
            renderTarget: Canvas.Image
            onPaint: {
                var ctx = gridCanvas.getContext('2d')

                ctx.clearRect(0,0,grid.width,grid.height)
                var step = 1000 / updateTimer.interval * (app.width / Data.heartData.length)
                var xCount = app.width / step
                var yCount = app.height / step
                ctx.strokeStyle = app.gridColor;

                var x=0;
                ctx.beginPath()
                for (var i=0; i<xCount; i++) {
                    x = i*step
                    ctx.moveTo(x,0)
                    ctx.lineTo(x,app.height)
                }
                ctx.stroke()
                ctx.closePath()

                var y=0;
                ctx.beginPath()
                for (var j=0; j<yCount; j++) {
                    y = j*step
                    ctx.moveTo(0, y)
                    ctx.lineTo(app.width,y)
                }
                ctx.stroke()
                ctx.closePath()
            }
        }
    }

    Rectangle {
        id: canvasBackground
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 0.75 * parent.height

        gradient: Gradient {
            GradientStop {position: .0; color :"black"}
            GradientStop {position: .5; color :"#00ff00"}
            GradientStop {position: 1.0; color :"black"}
        }
        opacity: .3
    }

    Item {
        id: canvasContainer
        anchors.fill: canvasBackground

        Canvas {
            id: heartCanvas
            anchors.fill: parent
            anchors.bottomMargin: 96
            anchors.topMargin: 196
            antialiasing: true
            renderTarget: Canvas.Image
            onPaint: {
                var ctx = heartCanvas.getContext('2d')

                ctx.clearRect(0,0,canvasContainer.width,canvasContainer.height)

                var baseY = heartCanvas.height/2;
                var length = Data.heartData.length;
                var step = (heartCanvas.width-5) / length;
                var yFactor = heartCanvas.height * 0.35;
                var heartIndex = (heartDataIndex+1) % length;
                ctx.strokeStyle = app.curveColor;

                ctx.beginPath()
                ctx.moveTo(0,baseY)
                var i=0, x=0, y=0;
                for (i=0; i<length; i++) {
                    x=i*step;
                    y=baseY - Data.heartData[heartIndex]*yFactor;
                    ctx.lineTo(x,y)
                    heartIndex = (heartIndex+1)%length;
                }
                ctx.stroke()
                ctx.closePath()

                ctx.beginPath()
                ctx.fillStyle = app.curveColor
                ctx.ellipse(x-5,y-5,10,10)
                ctx.fill()
                ctx.closePath()
            }
        }

        ToggleButton {
            id: button
            x: 686
            y: 295
            width: 76
            height: 76
            text: checked ? "On" : "Off"
            checked: true
            anchors.verticalCenterOffset: 134
            anchors.horizontalCenterOffset: 350
            anchors.centerIn: parent
            onClicked: Qt.quit()
        }
    }


    Image {
        id: heart
        x: 21
        y: 21
        width: 100
        height: 100
        source: "heart.png"
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: lungs
        x: 28
        y: 207
        width: 100
        height: 100
        source: "lungs.png"
        fillMode: Image.PreserveAspectFit
    }


    Text {
        id: pulseText
        anchors { right: parent.right; top: parent.top }
        x: 692
        y: 21
        width: 84
        height: 80
        antialiasing: true
        text: app.heartRate
        color: app.heartRate > 100 ? app.alarmColor : app.textColor
        font.pixelSize: 65
        anchors.topMargin: 21
        anchors.rightMargin: 67
        font.bold: true
    }

    Text {
        id: lungsText
        anchors { right: parent.right; top: parent.top }
        x: 692
        y: 279
        width: 82
        height: 80
        antialiasing: true
        color: app.respirationRate > 20 ? app.alarmColor : app.respirationColor
        anchors.rightMargin: 26
        text: app.respirationRate
        font.pixelSize: 65
        anchors.topMargin: 207
        font.bold: true
    }

    Text {
        id: text1
        x: 747
        y: 86
        width: 41
        height: 27
        color: "#ffffff"
        text: qsTr("bpm")
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        id: text2
        x: 761
        y: 269
        color: "#ffffff"
        text: qsTr("RR")
        font.pixelSize: 20
        font.bold: true
    }
    // Pulse timer
    Timer {
        id: heartTimer
        interval: 1200
        running: true
        repeat: false
        onTriggered: pulse()
    }

    // Update timer
    Timer {
        id: updateTimer
        interval: 300
        running: true
        repeat: true
        onTriggered: updateData()
    }

    SequentialAnimation{
        id: heartAnimation
        NumberAnimation { target: heart; property: "scale"; duration: 100; from: 1.0; to:1.2; easing.type: Easing.Linear }
        NumberAnimation { target: heart; property: "scale"; duration: 100; from: 1.2; to:1.0; easing.type: Easing.Linear }
    }

    SequentialAnimation{
        id: lungstAnimation
        NumberAnimation { target: lungs; property: "scale"; duration: 20; from: 1.0; to:1.2; easing.type: Easing.OutElastic }
        NumberAnimation { target: lungs; property: "scale"; duration: 20; from: 1.2; to:1.0; easing.type: Easing.OutElastic }
    }

    Component.onCompleted: {
        Data.fillHeartData(Math.max(100,Math.floor(app.width*0.5)))
    }

}
