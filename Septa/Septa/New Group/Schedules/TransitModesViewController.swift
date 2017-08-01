// SEPTA.org, created on 8/1/17.

import UIKit
import SeptaSchedule

class TransitModesViewController: UITableViewController {
    let segueId = "showRoutes"

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueId, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard let routesViewController = segue.destination as? RoutesViewController else { return }

        routesViewController.setRouteType(routeType: .bus)
    }
}
