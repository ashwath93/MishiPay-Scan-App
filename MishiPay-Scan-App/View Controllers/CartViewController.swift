//
//  CartViewController.swift
//  MishiPay-Scan-App
//
//  Created by Ashwath R on 29/11/20.
//

import UIKit
import CoreData

class CartViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    private var cartItems: [Item] = []
    private var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Cart"
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.reuseIdentifier)
        // Do any additional setup after loading the view.
        dataSource = DataSource(tableView: tableView) {
            tableView, indexPath, item in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = item.price.description
            if let imageData = item.image {
                cell.imageView?.backgroundColor = nil
                cell.imageView?.image = UIImage(data: imageData)
            } else {
                cell.imageView?.backgroundColor = .black
            }
            return cell
        }
        tableView.dataSource = dataSource
        dataSource.delegate = self
        fetchItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Utilities.saveCartItems(cartItems)
    }
    
    private func fetchItems() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(fetchRequest)
            guard let items = result.first?.items,
                  let cartItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(items) as? [Item] else { return }
            self.cartItems = cartItems
            var snapShot = NSDiffableDataSourceSnapshot<String, Item>()
            snapShot.appendSections(["main"])
            snapShot.appendItems(cartItems)
            dataSource.apply(snapShot, animatingDifferences: false)
        } catch {
            debugPrint("Unable to fetch items")
        }
    }
}

extension CartViewController: DataSourceDelegate {
    
    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            cartItems.remove(at: indexPath.row)
        default:
            break
        }
        var snapShot = NSDiffableDataSourceSnapshot<String, Item>()
        snapShot.appendSections(["main"])
        snapShot.appendItems(cartItems)
        dataSource.apply(snapShot, animatingDifferences: false)
    }
}

protocol DataSourceDelegate: AnyObject {
    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
}

class DataSource: UITableViewDiffableDataSource<String, Item> {
    
    weak var delegate: DataSourceDelegate?
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        delegate?.commit(editingStyle: editingStyle, forRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

class TableViewCell: UITableViewCell {
    static let reuseIdentifier: String = "TableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
