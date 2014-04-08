/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtTest 1.0
import "../../../qml/Components"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(30)
    height: units.gu(60)
    color: "lightgrey"

    property var widgetData0: {
        "source": "",
        "zoomable": false
    }

    property var widgetData1: {
        "source": "../../../qml/graphics/phone_background.jpg",
        "zoomable": false
    }

    property var widgetData2: {
        "source": "../../../qml/Dash/graphics/phone/screenshots/gallery@12.png",
        "zoomable": true
    }

    ZoomableImage {
        id: zoomableImage
        width: parent.width
        anchors.fill: parent
        asynchronous: false
    }

    SignalSpy {
        id: signalSpy
    }

    UT.UnityTestCase {
        name: "ZoomableImageTest"
        when: windowShown

        function test_loadImage() {
            var lazyImage = findChild(zoomableImage, "lazyImage");

            zoomableImage.source = widgetData0["source"];
            zoomableImage.zoomable = widgetData0["zoomable"];
            waitForRendering(zoomableImage);
            tryCompare(zoomableImage, "imageState", "default");

            signalSpy.signalName = "onStateChanged";
            signalSpy.target = lazyImage;
            signalSpy.clear();

            zoomableImage.source = widgetData1["source"];
            zoomableImage.zoomable = widgetData1["zoomable"];
            waitForRendering(lazyImage);
            tryCompareFunction(function() { return get_filename(lazyImage.source.toString()) === get_filename(widgetData1["source"]); }, true);
            waitForRendering(zoomableImage);
            tryCompare(zoomableImage, "imageState", "ready");
            compare (signalSpy.count, 1);
        }

        function get_filename(a) {
            var wordsA = a.split("/");
            var filenameA = wordsA[wordsA.length-1];
            return filenameA;
        }

        function test_pinch_data() {
            return [ { source:widgetData2["source"],
                       zoomable:false,
                       answer1: true,
                       answer2: false,
                       answer3: true,
                       answer4: 1.0 },
                     { source:widgetData2["source"],
                       zoomable:true,
                       answer1: false,
                       answer2: true,
                       answer3: false,
                       answer4: 1.7740461882048026 }
                   ]
        }

        function test_mousewheel() {
            var image = findChild(zoomableImage, "image");
            var lazyImage = findChild(zoomableImage, "lazyImage");
            var flickable = findChild(zoomableImage, "flickable");

            zoomableImage.source = widgetData2["source"];
            zoomableImage.zoomable = true;
            waitForRendering(zoomableImage);

            tryCompare(zoomableImage, "imageState", "ready");
            tryCompareFunction(function() { return get_filename(lazyImage.source.toString()) === get_filename(widgetData2["source"]); }, true);
            waitForRendering(image);

            // move mouse to center
            mouseMove(zoomableImage, zoomableImage.width / 2, zoomableImage.height / 2);

            // zoom in
            for (var i=0; i<10; i++) {
                mouseWheel(zoomableImage, zoomableImage.width / 2, zoomableImage.height / 2, 0, 10);
                tryCompare(image, "scale", 1.0 + (i + 1) * 0.1);
                compare(flickable.contentWidth, lazyImage.width * image.scale);
                compare(flickable.contentHeight, lazyImage.height * image.scale);
            }

            // zoom out
            for (var i=0; i<10; i++) {
                mouseWheel(zoomableImage, zoomableImage.width / 2, zoomableImage.height / 2, 0, -10);
                tryCompare(image, "scale", 2.0 - (i + 1) * 0.1);
                compare(flickable.contentWidth, lazyImage.width * image.scale);
                compare(flickable.contentHeight, lazyImage.height * image.scale);
            }
        }

        function test_pinch(data) {
            var image = findChild(zoomableImage, "image");
            var lazyImage = findChild(zoomableImage, "lazyImage");
            var flickable = findChild(zoomableImage, "flickable");

            signalSpy.signalName = "onScaleChanged";
            signalSpy.target = image;
            signalSpy.clear();

            zoomableImage.source = data.source;
            zoomableImage.zoomable = data.zoomable;
            waitForRendering(zoomableImage);

            tryCompare(zoomableImage, "imageState", "ready");
            tryCompareFunction(function() { return get_filename(lazyImage.source.toString()) === get_filename(data.source); }, true);
            waitForRendering(image);

            var x1Start = zoomableImage.width * 2 / 6;
            var y1Start = zoomableImage.height * 2 / 6;
            var x1End = zoomableImage.width * 1 / 6;
            var y1End = zoomableImage.height * 1 / 6;
            var x2Start = zoomableImage.width * 4 / 6;
            var y2Start = zoomableImage.height * 4 / 6;
            var x2End = zoomableImage.width * 5 / 6;
            var y2End = zoomableImage.height * 5 / 6;

            var oldScale = image.scale;

            // move mouse to center
            mouseMove(zoomableImage, zoomableImage.width / 2, zoomableImage.height / 2);

            var event1 = touchEvent();
            // first finger
            event1.press(0, x1Start, y1Start);
            event1.commit();
            // second finger
            event1.stationary(0);
            event1.press(1, x2Start, y2Start);
            event1.commit();

            // pinch
            for (var i = 0.0; i < 1.0; i += 0.02) {
                event1.move(0, x1Start + (x1End - x1Start) * i, y1Start + (y1End - y1Start) * i);
                event1.move(1, x2Start + (x2End - x2Start) * i, y2Start + (y2End - y2Start) * i);
                event1.commit();
            }

            // release
            event1.release(0, x1End, y1End);
            event1.release(1, x2End, y2End);
            event1.commit();

            tryCompare(image, "scale", data.answer4);
            var newScale = image.scale;
            compare(newScale == oldScale, data.answer1, "scale factor not equal: "+ oldScale + "=?" + newScale);
            compare(newScale > oldScale, data.answer2, "scale factor didn't changed");
            compare(signalSpy.count == 0, data.answer3, "scale signal count error");
            compare(newScale, data.answer4, "scale factor error");
            compare(flickable.contentWidth, lazyImage.width * image.scale);
            compare(flickable.contentHeight, lazyImage.height * image.scale);
        }
    }
}
