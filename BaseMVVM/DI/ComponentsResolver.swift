//
//  ComponentsResolver.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 02.04.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

public typealias ComponentFactory<Component> = () -> Component

public final class ComponentsResolver
{
    nonisolated(unsafe) public static let shared = ComponentsResolver()
    
    private var factories = [String: Any]()
    private var components = [String: Any]()
    private var lock = NSRecursiveLock()
    
    public func Register<Component>( type: Component.Type, lazy: Bool = true, factory: @escaping ComponentFactory<Component> )
    {
        lock.lock()
        defer { lock.unlock() }
        
        let name = String( describing: type.self )
        factories[name] = factory
        if !lazy
        {
            components[name] = factory()
        }
    }
    
    public func Provide<Component>( type: Component.Type, singleton: Bool ) -> Component
    {
        lock.lock()
        defer { lock.unlock() }
        
        let name = String( describing: type.self )
        if singleton
        {
            var component = components[name]
            if component == nil
            {
                component = (factories[name] as! ComponentFactory<Component>)()
                components[name] = component
            }
            return component as! Component
        }

        return (factories[name] as! ComponentFactory<Component>)()
    }
}
