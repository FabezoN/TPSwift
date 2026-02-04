import Foundation

@MainActor
var movies: [(title: String, year: Int, rating: Double, genre: String)] = [
    (title: "Inception", year: 2010, rating: 8.8, genre: "Sci-Fi"),
    (title: "The Dark Knight", year: 2008, rating: 9.0, genre: "Action"),
    (title: "Interstellar", year: 2014, rating: 8.6, genre: "Sci-Fi"),
    (title: "Parasite", year: 2019, rating: 8.6, genre: "Drama"),
    (title: "Avengers: Endgame", year: 2019, rating: 8.4, genre: "Action"),
    (title: "Joker", year: 2019, rating: 8.4, genre: "Drama"),
    (title: "Coco", year: 2017, rating: 8.4, genre: "Animation"),
    (title: "The Lion King", year: 1994, rating: 8.5, genre: "Animation"),
    (title: "Pulp Fiction", year: 1994, rating: 8.9, genre: "Crime"),
    (title: "Forrest Gump", year: 1994, rating: 8.8, genre: "Drama")
]

func displayMovie(_ movie: (title: String, year: Int, rating: Double, genre: String)) {
    print("📽️  \(movie.title) (\(movie.year)) - \(movie.genre)")
    print("⭐ Rating: \(movie.rating)/10")
    print("---------------------------------")
}

func addMovie(title: String, year: Int, rating: Double, genre: String, to movies: inout [(title: String, year: Int, rating: Double, genre: String)]) {
    let newMovie = (title: title, year: year, rating: rating, genre: genre)
    movies.append(newMovie)
    print("✅ Film ajouté avec succès !")
}

func findMovie(byTitle title: String, in movies: [(title: String, year: Int, rating: Double, genre: String)]) -> (title: String, year: Int, rating: Double, genre: String)? {
    return movies.first { $0.title.lowercased() == title.lowercased() }
}

func filterMovies(_ movies: [(title: String, year: Int, rating: Double, genre: String)], matching criteria: ((title: String, year: Int, rating: Double, genre: String)) -> Bool) -> [(title: String, year: Int, rating: Double, genre: String)] {
    return movies.filter(criteria)
}

func getUniqueGenres(from movies: [(title: String, year: Int, rating: Double, genre: String)]) -> Set<String> {
    return Set(movies.map { $0.genre })
}

func averageRating(of movies: [(title: String, year: Int, rating: Double, genre: String)]) -> Double {
    if movies.isEmpty { return 0.0 }
    let total = movies.reduce(0.0) { $0 + $1.rating }
    return total / Double(movies.count)
}

func bestMovie(in movies: [(title: String, year: Int, rating: Double, genre: String)]) -> (title: String, year: Int, rating: Double, genre: String)? {
    return movies.max { $0.rating < $1.rating }
}

func moviesByDecade(_ movies: [(title: String, year: Int, rating: Double, genre: String)]) -> [String: [(title: String, year: Int, rating: Double, genre: String)]] {
    var dictionary: [String: [(title: String, year: Int, rating: Double, genre: String)]] = [:]
    
    for movie in movies {
        let decadeVal = (movie.year / 10) * 10
        let decadeKey = "\(decadeVal)s"
        
        if dictionary[decadeKey] == nil {
            dictionary[decadeKey] = []
        }
        dictionary[decadeKey]?.append(movie)
    }
    return dictionary
}

func displayMenu() {
    print("\n=== 🎬 Movie Manager ===")
    print("1. Afficher tous les films")
    print("2. Rechercher un film")
    print("3. Filtrer par genre")
    print("4. Afficher les statistiques")
    print("5. Ajouter un film")
    print("6. Afficher le CSV (Console)")
    print("7. Exporter le CSV (Fichier)")
    print("8. Quitter")
    print("Votre choix : ", terminator: "")
}

@MainActor
func startTp1MovieManager() {
    var isRunning = true
    
    while isRunning {
        displayMenu()
        
        if let choice = readLine() {
            print("")
            
            switch choice {
            case "1":
                print("--- Tous les films ---")
                for m in movies {
                    displayMovie(m)
                }
                
            case "2":
                print("Titre à chercher : ", terminator: "")
                let t = readLine() ?? ""
                let found = findMovie(byTitle: t, in: movies)
                if found != nil {
                    displayMovie(found!)
                } else {
                    print("Film non trouvé")
                }
                
            case "3":
                let allGenres = getUniqueGenres(from: movies)
                print("Genres : \(allGenres)")
                print("Lequel ? ", terminator: "")
                let g = readLine() ?? ""
                
                let res = filterMovies(movies) { (movie) -> Bool in
                    return movie.genre == g
                }
                
                if res.isEmpty {
                    print("Rien trouvé.")
                } else {
                    for m in res {
                        displayMovie(m)
                    }
                }
                
            case "4":
                print("--- Stats ---")
                print("Total: \(movies.count)")
                print("Moyenne: \(averageRating(of: movies))")
                if let best = bestMovie(in: movies) {
                    print("Meilleur: \(best.title)")
                }
                print("Par décennie :")
                let dict = moviesByDecade(movies)
                for (k, v) in dict {
                    print("\(k) : \(v.count) films")
                }
                
            case "5":
                print("Titre: ", terminator: "")
                let t = readLine()!
                print("Année: ", terminator: "")
                let y = Int(readLine()!)!
                print("Note: ", terminator: "")
                let r = Double(readLine()!)!
                print("Genre: ", terminator: "")
                let g = readLine()!
                
                addMovie(title: t, year: y, rating: r, genre: g, to: &movies)
                
            case "6":
                print("--- Aperçu CSV ---")
                let content = exportToCSV(movies)
                print(content)
                
            case "7":
                print("Nom du fichier (ex: films.csv) : ", terminator: "")
                let filename = readLine() ?? "movies.csv"
                saveCSV(movies, to: filename)
                
            case "8":
            print("Bye!")
            isRunning = false
                
            default:
                print("Erreur système")
            }
        }
    }
}

// ==========================================
// PARTIE 5 : Bonus (CSV)
// ==========================================

func exportToCSV(_ movies: [(title: String, year: Int, rating: Double, genre: String)]) -> String {
    var csvContent = "Title,Year,Rating,Genre\n"
    
    for movie in movies {
        let safeTitle = movie.title.replacingOccurrences(of: ",", with: ";")
        let line = "\(safeTitle),\(movie.year),\(movie.rating),\(movie.genre)\n"
        csvContent += line
    }
    return csvContent
}

func saveCSV(_ movies: [(title: String, year: Int, rating: Double, genre: String)], to filename: String) {
    let csvString = exportToCSV(movies)
    
    if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = documentDirectory.appendingPathComponent(filename)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("✅ Fichier sauvegardé ici : \(fileURL.path)")
        } catch {
            print("❌ Erreur lors de la sauvegarde : \(error)")
        }
    }
}
