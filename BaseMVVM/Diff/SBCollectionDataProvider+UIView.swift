//
//  SBCollectionDataProvider+UIView.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 12.05.2022.
//  Copyright © 2022 ALEXEY ABDULIN. All rights reserved.
//

import UIKit

extension SBCollectionDataProvider
{
    public func Dispatch( newItems: CollectionSection, to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil )
    {
        if startReload
        {
            Set( items: newItems )
            if newItems.count > 0
            {
                to.reloadData()
                if reverse
                {
                    let numSec = to.numberOfSections
                    let numRow = to.numberOfRows( inSection: numSec - 1 )
                    to.scrollToRow( at: IndexPath( row: numRow - 1, section: numSec - 1 ), at: .bottom, animated: false )
                }
            }
        }
        else
        {
            CalculateChanges( newItems: newItems )
            
            if logging
            {
                print( "INSERT SECTIONS: - \(insertedSections)" )
                print( "DELETE SECTIONS: - \(deleteSections)" )
                
                print( "CHANGES: - \(changedItems)" )
                print( "MOVES: - \(movedItems)" )
                print( "INSERTS: - \(insertedItems)" )
                print( "DELETES: - \(deletedItems)" )
            }
            
            var moveIndex: IndexPath? = nil
            
            if reverse, let visibleRows = to.indexPathsForVisibleRows, var cellIndex = visibleRows.last
            {
                if let cell = to.cellForRow( at: cellIndex )
                {
                    if #available(iOS 11.0, *), logging
                    {
                        print( "CELL Y: \(cell.frame.origin.y) ; CONTENT OFFSET: \(to.contentOffset.y) ; CONTENT SIZE: \(to.contentSize.height) ; BOTTOM: \(to.safeAreaInsets.bottom)" )
                        print( "CELL Y - OFFSET: \(cell.frame.origin.y - to.contentOffset.y); CELL HEIGHT: \(cell.frame.height) ; TABLE HEIGHT: \(to.frame.height)" )
                    }
                    else
                    {
                        
                    }
                    
                    let y = cell.frame.origin.y - to.contentOffset.y
                    if ((y + cell.frame.height) > to.frame.height) && (visibleRows.count > 1)
                    {
                        cellIndex = visibleRows[visibleRows.count - 2]
                    }
                }
                
                var section = cellIndex.section, row = cellIndex.row
                insertedSections.forEach
                {
                    if $0 <= cellIndex.section
                    {
                        section += 1
                    }
                }
                
                for i in insertedItems where i.newSec == section
                {
                    if i.newI < cellIndex.row
                    {
                        row += 1
                    }
                }
                
                moveIndex = IndexPath( row: row, section: section )
                if logging
                {
                    print( "MOVE FROM: \(cellIndex) TO: \(moveIndex!)" )
                }
            }
            
            if all == UITableView.RowAnimation.none
            {
                UIView.setAnimationsEnabled( false )
            }
                
            if #available(iOS 11.0, *)
            {
                to.performBatchUpdates(
                {
                    [weak self] in
                    self?._ProcessUpdates( to: to, change: change, insert: insert, delete: delete, all: all )
                    self?.CommitChanges()
                }, completion: nil )
            }
            else
            {
                to.beginUpdates()
                _ProcessUpdates( to: to, change: change, insert: insert, delete: delete, all: all )
                CommitChanges()
                to.endUpdates()
            }
            
            if all == UITableView.RowAnimation.none
            {
                UIView.setAnimationsEnabled( true )
            }
            
            if let moveIndex = moveIndex
            {
                let sections = to.numberOfSections
                let realSection = min( sections - 1, moveIndex.section )
                let rows = to.numberOfRows( inSection: realSection )
                to.scrollToRow( at: IndexPath( item: min( rows - 1, moveIndex.row ), section: realSection ), at: .none, animated: false )
                to.panGestureRecognizer.isEnabled = false
                
                DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + 0.05 )
                {
                    to.panGestureRecognizer.isEnabled = true
                }
                /*
                if to.isDecelerating, let indexes = to.indexPathsForVisibleRows, indexes.count > 2
                {
                    let preLastIndex = indexes[indexes.count - 2]
                    to.scrollToRow( at: preLastIndex, at: .bottom, animated: true )
                }*/
            }
        }
    }
    
    private func _ProcessUpdates( to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil )
    {
        let changeIndeces = changedItems.map { $0.newRow }
        let deleteIndeces = deletedItems.map { $0.oldRow }
        let insertIndeces = insertedItems.map { $0.newRow }
        
        if !insertedSections.isEmpty
        {
            to.insertSections( IndexSet( insertedSections ), with: all ?? insert )
        }
        
        if !deleteSections.isEmpty
        {
            to.deleteSections( IndexSet( deleteSections ), with: all ?? delete )
        }
        
        to.reloadRows( at: changeIndeces, with: all ?? change )
        movedItems.forEach
        {
            if deleteIndeces.contains( $0.oldRow ) || deleteIndeces.contains( $0.newRow ) || insertIndeces.contains( $0.newRow ) || insertIndeces.contains( $0.oldRow ) || $0.state == .movedChanged
            {
                to.deleteRows( at: [$0.oldRow], with: .automatic )
                to.insertRows( at: [$0.newRow], with: .automatic )
            }
            else
            {
                //to.reloadRows( at: [$0.oldIndex], with: .none )
                to.moveRow( at: $0.oldRow, to: $0.newRow )
            }
        }
        
        to.deleteRows( at: deleteIndeces, with: all ?? delete )
        to.insertRows( at: insertIndeces, with: all ?? insert )
    }
}


extension SBCollectionDataProvider
{
    public func Dispatch( newItems: CollectionSection, to: UICollectionView )
    {
        if startReload
        {
            Set( items: newItems )
            if newItems.count > 0
            {
                to.reloadData()
                if reverse
                {
                    let numSec = to.numberOfSections
                    let numRow = to.numberOfItems( inSection: numSec - 1 )
                    to.scrollToItem( at: IndexPath( row: numRow - 1, section: numSec - 1 ), at: .bottom, animated: false )
                }
            }
        }
        else
        {
            CalculateChanges( newItems: newItems )
            
            if logging
            {
                print( "INSERT SECTIONS: - \(insertedSections)" )
                print( "DELETE SECTIONS: - \(deleteSections)" )
                
                print( "CHANGES: - \(changedItems)" )
                print( "MOVES: - \(movedItems)" )
                print( "INSERTS: - \(insertedItems)" )
                print( "DELETES: - \(deletedItems)" )
            }
            
            to.performBatchUpdates(
            {
                [weak self] in
                
                self?._ProcessUpdates( to: to )
                self?.CommitChanges()
            }, completion: nil )
        }
    }
    
    private func _ProcessUpdates( to: UICollectionView )
    {
        let changeIndeces = changedItems.map { $0.newItem }
        let deleteIndeces = deletedItems.map { $0.oldItem }
        let insertIndeces = insertedItems.map { $0.newItem }
        
        if !insertedSections.isEmpty
        {
            to.insertSections( IndexSet( insertedSections ) )
        }
        
        if !deleteSections.isEmpty
        {
            to.deleteSections( IndexSet( deleteSections ) )
        }
        
        to.reloadItems( at: changeIndeces )
        movedItems.forEach
        {
            if deleteIndeces.contains( $0.oldItem ) || deleteIndeces.contains( $0.newItem ) || insertIndeces.contains( $0.newItem ) || insertIndeces.contains( $0.oldItem ) || $0.state == .movedChanged
            {
                to.deleteItems( at: [$0.oldItem] )
                to.insertItems( at: [$0.newItem] )
            }
            else
            {
                //to.reloadRows( at: [$0.oldIndex], with: .none )
                to.moveItem( at: $0.oldItem, to: $0.newItem )
            }
        }
        
        to.deleteItems( at: deleteIndeces )
        to.insertItems( at: insertIndeces )
    }
}
