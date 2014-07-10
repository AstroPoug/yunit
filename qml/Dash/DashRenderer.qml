/*
 * Copyright (C) 2013 Canonical, Ltd.
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

Item {
    property int collapsedHeight: height

    property int expandedHeight: height

    property int displayMarginBeginning: 0

    property int displayMarginEnd: 0

    property real originY: 0

    // The model to renderer
    property var model

    /// CardTool component.
    property var cardTool: null

    /// ScopeStyle component.
    property var scopeStyle: null

    /// Emitted when the user clicked on an item
    /// @param index is the index of the clicked item
    /// @param result result model of the cliked item, used for activation
    signal clicked(int index, var result)

    /// Emitted when the user pressed and held on an item
    /// @param index is the index of the held item
    signal pressAndHold(int index)
}
