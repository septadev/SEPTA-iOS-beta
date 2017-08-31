if state.updateMode == .loadValues && state.routes.count == 0 {
            selectRoutesViewController?.displayErrorMessage(message: SeptaString.NoRoutesAvailable)
        }

        selectRoutesViewController?.viewModelUpdated()