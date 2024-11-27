//
//  ViewController.swift
//  SuperHero
//
//  Created by Falko 20.11.2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var heroImage: UIImageView!
    @IBOutlet private weak var heroName: UILabel!
    @IBOutlet private weak var heroGender: UILabel!
    @IBOutlet private weak var heroPower: UILabel!
    @IBOutlet private weak var heroPlaceOfBirth: UILabel!
    @IBOutlet private weak var heroFullName: UILabel!
    @IBOutlet private weak var heroIntelligence: UILabel!
    @IBOutlet private weak var heroAliases: UILabel!
    @IBOutlet private weak var heroCombat: UILabel!
    @IBOutlet private weak var heroWeight: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction private func heroButtonDidTap(_ sender: UIButton) {
        fetchHeroes()
    }
    
    private func fetchHeroes() {
        let session = URLSession(configuration: .default)
        let urlString = "https://akabab.github.io/superhero-api/api/all.json"
        guard let url = URL(string: urlString) 
        else {
            return
        }
        let urlRequest = URLRequest(url: url)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error {
                print(error.localizedDescription)
            } else {
                guard let data else { return }
                self.decodeHeroResponse(heroData: data)
            }
        }
        task.resume()
    }
    
    private func decodeHeroResponse(heroData: Data) {
        do {
            let heroes = try JSONDecoder().decode([Hero].self, from: heroData)
            guard let selectedHero = heroes.randomElement() else { return }

            DispatchQueue.main.async {
                self.updateUI(selectedHero: selectedHero)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func updateUI(selectedHero: Hero){
        self.heroName.text = selectedHero.name
        fetchHeroImage(imageString: selectedHero.images.sm)
        let power = selectedHero.powerstats.power
        let intelligence = selectedHero.powerstats.intelligence
        let combat = selectedHero.powerstats.combat
        let weight = selectedHero.appearance.weight
        self.heroPower.text = "\(power)"
        self.heroGender.text = selectedHero.appearance.gender
        self.heroPlaceOfBirth.text = selectedHero.biography.placeOfBirth
        self.heroFullName.text = selectedHero.biography.fullName
        self.heroIntelligence.text = "\(intelligence)"
        self.heroAliases.text = selectedHero.biography.aliases
        self.heroCombat.text = "\(combat)"
        self.heroWeight.text = "\(weight)"
    }
    
    private func fetchHeroImage(imageString: String) {
        guard let url = URL(string: imageString) else {
            return
        }
        
        DispatchQueue.global().async {
            let imageData = try! Data(contentsOf: url)
            DispatchQueue.main.async {
                self.heroImage.image = UIImage(data: imageData)
            }
        }
    }
    
    struct Hero: Decodable{
        let name: String
        let images: HeroImage
        let appearance: HeroAppearance
        let powerstats: HeroPowerstats
        let biography: Biography
        
        struct HeroImage: Decodable{
            let sm: String
        }
        struct HeroAppearance: Decodable{
            let gender: String
            let weight: String
        }
        struct HeroPowerstats: Decodable{
            let power: Int
            let intelligence: Int
            let combat: Int
            
        }
        struct Biography: Decodable{
            let placeOfBirth: String
            let fullName: String
            let aliases: String
        }
        
    }
    

}

