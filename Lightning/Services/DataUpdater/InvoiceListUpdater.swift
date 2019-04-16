//
//  Lightning
//
//  Created by 0 on 02.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Logger
import SwiftLnd

final class InvoiceListUpdater: GenericListUpdater {
    typealias Item = Invoice

    private let api: LightningApiProtocol

    let items = MutableObservableArray<Invoice>()

    init(api: LightningApiProtocol) {
        self.api = api

        api.subscribeInvoices { [weak self] in
            if case .success(let invoice) = $0 {
                Logger.info("new invoice: \(invoice)")

                if self?.appendOrReplace(invoice) == true && invoice.state == .settled {
                    NotificationCenter.default.post(name: .receivedTransaction, object: nil, userInfo: [LightningService.transactionNotificationName: invoice])
                }
            }
        }
    }

    func update() {
        api.invoices { [weak self] in
            if case .success(let invoices) = $0 {
                self?.items.replace(with: invoices)
            }
        }
    }
}