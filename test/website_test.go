package test

import (
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestWebsiteInfrastructure(t *testing.T) {
	t.Parallel()

	// Générer un nom de bucket unique pour éviter les conflits
	uniqueID := random.UniqueId()
	bucketName := fmt.Sprintf("terratest-website-bucket-%s", uniqueID)
	
	// Configurer les options Terraform
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Le chemin vers votre code Terraform
		TerraformDir: "../",

		// Variables à passer à votre code Terraform
		Vars: map[string]interface{}{
			"aws_region":         "eu-west-3",
			"bucket_name":        bucketName,
			"domain_name":        fmt.Sprintf("test-%s.exemple.com", uniqueID),
			"create_route53_zone": false,
			"route53_zone_id":    "", // Pas besoin pour les tests
		},
	})

	// Nettoyer les ressources à la fin du test
	defer terraform.Destroy(t, terraformOptions)

	// Déployer l'infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Récupérer les outputs
	bucketName = terraform.Output(t, terraformOptions, "website_bucket_name")
	s3Endpoint := terraform.Output(t, terraformOptions, "website_endpoint")
	cloudfrontDomain := terraform.Output(t, terraformOptions, "cloudfront_domain_name")

	// Vérifier que le bucket existe
	aws.AssertS3BucketExists(t, "eu-west-3", bucketName)

	// Télécharger un fichier de test dans le bucket
	awsRegion := "eu-west-3"
	testContent := "<!DOCTYPE html><html><body><h1>Test Page</h1></body></html>"
	aws.PutS3Object(t, awsRegion, bucketName, "index.html", testContent)

	// Attendre que le contenu soit disponible via S3 website endpoint
	maxRetries := 30
	timeBetweenRetries := 10 * time.Second
	url := fmt.Sprintf("http://%s", s3Endpoint)

	http.DefaultTransport.(*http.Transport).TLSClientConfig = nil

	retry(t, maxRetries, timeBetweenRetries, func() bool {
		resp, err := http.Get(url)
		if err != nil {
			t.Logf("Erreur lors de l'accès à %s: %v", url, err)
			return false
		}
		defer resp.Body.Close()
		return resp.StatusCode == 200
	})

	// Note: Tester CloudFront nécessiterait d'attendre la propagation du déploiement
	// ce qui peut prendre jusqu'à 15-30 minutes, donc nous le commentons ici
	/*
	cloudfrontUrl := fmt.Sprintf("https://%s", cloudfrontDomain)
	retry(t, 10, 60*time.Second, func() bool {
		resp, err := http.Get(cloudfrontUrl)
		if err != nil {
			t.Logf("Erreur lors de l'accès à %s: %v", cloudfrontUrl, err)
			return false
		}
		defer resp.Body.Close()
		return resp.StatusCode == 200
	})
	*/

	// Vérifier les outputs
	assert.NotEmpty(t, bucketName, "Le nom du bucket ne devrait pas être vide")
	assert.NotEmpty(t, s3Endpoint, "L'endpoint S3 ne devrait pas être vide")
	assert.NotEmpty(t, cloudfrontDomain, "Le domaine CloudFront ne devrait pas être vide")
}

// Fonction utilitaire pour réessayer une opération
func retry(t *testing.T, maxRetries int, timeBetweenRetries time.Duration, operation func() bool) {
	for i := 0; i < maxRetries; i++ {
		if operation() {
			return
		}
		time.Sleep(timeBetweenRetries)
	}
	t.Fatal("Nombre maximum de tentatives atteint")
} 