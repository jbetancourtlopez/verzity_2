
import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let univ1 = TabUniversityViewController()
        univ1.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        
        let univ2 = TabUniversityViewController()
        univ2.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        
        let univ3 = TabUniversityViewController()
        univ3.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
        
        self.viewControllers = [univ1, univ2, univ3]
    }
}
