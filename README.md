# EventApp

Application de gestion d'événements avec paiement via Stripe Checkout.

## Configuration de Stripe

Cette application utilise Stripe Checkout pour les paiements. Voici comment configurer Stripe pour votre environnement :

### 1. Clés API

Assurez-vous que les variables d'environnement suivantes sont définies dans votre fichier `.env` :

```
STRIPE_PUBLISHABLE_KEY = "votre_clé_publique"
STRIPE_SECRET_KEY = "votre_clé_secrète"
STRIPE_WEBHOOK_SECRET = "votre_clé_webhook"
```

### 2. Configuration du Webhook

Pour que les paiements soient correctement traités, vous devez configurer un webhook Stripe :

1. Connectez-vous à votre [dashboard Stripe](https://dashboard.stripe.com/)
2. Allez dans Développeurs > Webhooks > Ajouter un endpoint
3. Pour le développement local, utilisez [Stripe CLI](https://stripe.com/docs/stripe-cli) pour tester les webhooks :
   ```
   stripe listen --forward-to localhost:3000/stripe-webhook
   ```
4. Pour la production, entrez l'URL de votre application suivie de `/stripe-webhook`
5. Sélectionnez l'événement `checkout.session.completed`
6. Copiez la clé de signature du webhook et ajoutez-la à votre variable d'environnement `STRIPE_WEBHOOK_SECRET`

### 3. Test des paiements

En mode développement, vous pouvez :
- Simuler un paiement sans utiliser Stripe
- Tester Stripe Checkout avec les [cartes de test Stripe](https://stripe.com/docs/testing#cards)

## Fonctionnement

1. Un utilisateur s'inscrit à un événement payant
2. Il est redirigé vers la page de paiement Stripe Checkout
3. Après paiement, il est redirigé vers la page de l'événement
4. Le webhook Stripe confirme le paiement et crée l'inscription

## Développement

Pour lancer l'application en mode développement :

```
bundle install
rails db:migrate
rails server
```

Pour tester les webhooks en local, utilisez Stripe CLI comme mentionné ci-dessus.