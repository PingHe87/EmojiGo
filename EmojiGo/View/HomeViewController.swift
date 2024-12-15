//  HomeViewController.swift
//  EmojiGo
//  Created by p h on 12/14/24.

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Set background color
        self.view.backgroundColor = .white

        // Add title image view
        let titleImageView = UIImageView(image: UIImage(named: "Title"))
        titleImageView.contentMode = .scaleAspectFit
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleImageView)

        // Add "Start Game" button
        let startGameButton = UIButton(type: .system)
        startGameButton.setTitle("Start Game", for: .normal)
        startGameButton.titleLabel?.font = UIFont(name: "Impact", size: 30)
        startGameButton.setTitleColor(UIColor(red: 0.976, green: 0.859, blue: 0.322, alpha: 1.0), for: .normal)
        startGameButton.backgroundColor = UIColor(red: 1.0, green: 0.271, blue: 0.271, alpha: 1.0)
        startGameButton.layer.cornerRadius = 10
        startGameButton.addTarget(self, action: #selector(startGameTapped), for: .touchUpInside)
        startGameButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(startGameButton)

        NSLayoutConstraint.activate([
            // Title image view constraints
            titleImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
            titleImageView.heightAnchor.constraint(equalToConstant: 110),

            // Start game button constraints
            startGameButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            startGameButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc private func startGameTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let gameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? ViewController {
            gameVC.modalTransitionStyle = .crossDissolve
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true, completion: nil)
        }
    }
}

