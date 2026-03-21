<div align="center">
<img src="https://github.com/PhilippeRuffieux/sqily/blob/main/app/assets/images/sqily.png"
         alt="Sqily logo">
  <h4>Mutual Validation of Skills (MVS)</h4>
</div>

## Contents
- [Objective](#-objective)
- [Development](#-developement)
- [Deploy](#-deploy)
- [Sponsor](#-sponsor)

<br>

## 🎓 Objective

<a href="https://www.sqily.com">Sqily.com</a> is a platform for school communication and mutual validation of skills, provided by the University of Teacher Education, State of Vaud (HEP Vaud). It is a web application built using ![Rails](https://img.shields.io/badge/framework-Ruby_on_Rails-CC0000)

Based on reasearch findings about deep learning when learners are expected to teach, the mutual validation fo skills (MVS) method emerged from experiments with knowledge trees (Authier, Lévy) adapted to practical realities from the teachers.

The digital solution enables, in particular:
- Creating skills-based learning pathways
- Providing structured content for each skill to facilitate self-directed learning
- Identifying the skills of the community and of each learner and tracking their progress
- Connecting more advanced learners (the experts) around a validation process (the challenge)
- Valuing knowledge of the community and highlighting the learner’s own strengths drive the learning path
- Enable peer assessment in a formative manner (the challenges) or in a more summative manner through the certification portfolio (the articles)

<img src="https://edutechwiki.unige.ch/fmediawiki/images/a/a1/Arbre_connaissances_sqily.png"
         alt="parcours / arbre de la communauté">

More informations (in french)
- <a href="https://sqily.com/pages/faq">FAQ sur Sqily</a>
- <a href="https://sites.google.com/view/validationmutuellecompetences/accueil">Explication de la VMC</a>

<br>

## 🐳 Developement

Run `docker compose up --build` to start the database and the server.

If necessary, run `docker compose run web bin/rails console` to create a few users and communities.
This will load the test data from `test/fixtures`.
The admin account is admin@sqily.test / password.

<br>

## 🚥 Deploy

Every change made to `master` is automatically deployed to production.

<br>

## 💰 Sponsor

<a href="https://www.hepl.ch/">HEP Vaud</a> funded the project between 2015 and 2018. Since then, it has been covering the maintenance costs.
