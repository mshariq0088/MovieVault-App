//
//  CoreDataStack.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 10/09/25.
//

import Foundation
import CoreData


final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    private init() {
        let model = Self.makeModel()
        persistentContainer = NSPersistentContainer(name: "MovieVault", managedObjectModel: model)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error { fatalError("Unresolved Core Data error: \(error)") }
        }
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveIfNeeded() {
        let ctx = persistentContainer.viewContext
        if ctx.hasChanges {
            do { try ctx.save() } catch { print("CoreData save error: \(error)") }
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // MovieEntity
        let entity = NSEntityDescription()
        entity.name = "MovieEntity"
        entity.managedObjectClassName = NSStringFromClass(MovieEntity.self)

        // Attributes
        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .integer64AttributeType
        id.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        let overview = NSAttributeDescription()
        overview.name = "overview"
        overview.attributeType = .stringAttributeType
        overview.isOptional = true

        let posterPath = NSAttributeDescription()
        posterPath.name = "posterPath"
        posterPath.attributeType = .stringAttributeType
        posterPath.isOptional = true

        let backdropPath = NSAttributeDescription()
        backdropPath.name = "backdropPath"
        backdropPath.attributeType = .stringAttributeType
        backdropPath.isOptional = true

        let releaseDate = NSAttributeDescription()
        releaseDate.name = "releaseDate"
        releaseDate.attributeType = .stringAttributeType
        releaseDate.isOptional = true

        let voteAverage = NSAttributeDescription()
        voteAverage.name = "voteAverage"
        voteAverage.attributeType = .doubleAttributeType
        voteAverage.isOptional = true

        let isBookmarked = NSAttributeDescription()
        isBookmarked.name = "isBookmarked"
        isBookmarked.attributeType = .booleanAttributeType
        isBookmarked.isOptional = false
        isBookmarked.defaultValue = false

        let updatedAt = NSAttributeDescription()
        updatedAt.name = "updatedAt"
        updatedAt.attributeType = .dateAttributeType
        updatedAt.isOptional = false
        updatedAt.defaultValue = Date(timeIntervalSince1970: 0)

        entity.properties = [id, title, overview, posterPath, backdropPath, releaseDate, voteAverage, isBookmarked, updatedAt]

        model.entities = [entity]
        return model
    }
}

@objc(MovieEntity)
final class MovieEntity: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String
    @NSManaged var overview: String?
    @NSManaged var posterPath: String?
    @NSManaged var backdropPath: String?
    @NSManaged var releaseDate: String?
    @NSManaged var voteAverage: Double
    @NSManaged var isBookmarked: Bool
    @NSManaged var updatedAt: Date
}

extension MovieEntity {
    func toDomain() -> Movie {
        Movie(
            id: Int(id),
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage
        )
    }

    func update(from movie: Movie) {
        id = Int64(movie.id)
        title = movie.title
        overview = movie.overview
        posterPath = movie.posterPath
        backdropPath = movie.backdropPath
        releaseDate = movie.releaseDate
        voteAverage = movie.voteAverage ?? 0
        updatedAt = Date()
    }
}


