//
//  Last50DaysViewModel.swift
//  NasaAPOD
//
//  Created by Mehboob Alam on 25.12.21.
//

import Foundation


public class Last50DaysViewModel {
    /// Filtered list on the basis of date
    private var filteredList: [APODDataModel]?
    public private(set) var signal: PublishSubject<Void>!
    private let apiClient: APODAPIType
    private var holder: PublishSubject<[APODDataModel]>?

    /// Data list for captreing orgioonal data from newtork
    private var dataList: [APODDataModel]? {
        willSet {
            filteredList = newValue
        }
    }

    public init(apiClient: APODAPIType) {
        self.apiClient = apiClient
        self.signal = .init()
    }

    deinit {
        signal.subscribe(onNext: nil, onError: nil, onComplete: nil)
    }

    public func sendRequestForLast50Images() {
        holder = apiClient.sendApodLast50Days()
        holder?.subscribe(onNext: { [weak self] list in
            self?.dataList = list
            DispatchQueue.main.async {
                self?.signal.onNext(())
            }
        }, onError: { [weak self] error in
            DispatchQueue.main.async {
                self?.signal.onError(error)
            }
        })
    }

    public func filter(forDate date: Date?) {
        if date == nil {
            filteredList = dataList
            return
        }
        filteredList = dataList?.filter({ $0.date?.getString(format: .yyyy_MM_dd) == date?.getString(format: .yyyy_MM_dd)}) ?? []
    }

    public var numberOfRows: Int {
        return filteredList?.count ?? 0
    }

    public func getItem(at index: Int) -> APODDataModel? {
        filteredList?[index]
    }
}
