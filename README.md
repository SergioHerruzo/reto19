# Terraform Multi-Environment Setup

Aquesta és l'estructura Terraform per a un projecte multi-entorn dissenyat per a AWS Academy. Utilitza mòduls compartits i directoris separats per cada entorn (`dev`, `staging`, i `prod`).

## Descripció de l'Estructura

- **`modules/`**: Conté els recursos reutilitzables de Terraform (VPC, EC2, RDS i S3). Amb això ens assegurem que el codi segueix el principi DRY (Don't Repeat Yourself).
- **`environments/`**: Conté els diferents entorns de desplegament.
    - **`dev/`**: Entorn de desenvolupament (Instàncies `t2.micro`).
    - **`staging/`**: Entorn de proves amb una arquitectura similar a producció (`t2.small`). Inclou VPC Peering amb `dev`.
    - **`prod/`**: Entorn de producció, totalment aïllat (`t2.small`).

## Justificació: Workspaces vs Directoris Separats

Per a aquest projecte s'ha triat una **estructura basada en directoris separats** en lloc de Terraform Workspaces.

**Per què directoris separats?**
1. **Aïllament Clar:** Utilitzar directoris proporciona una divisió física entre entorns. És completament impossible aplicar per accident canvis de `dev` a `prod` perquè has d'estar explícitament al directori correcte.
2. **Backend Separat:** Cada directori té el seu propi fitxer d'estat a S3. Amb workspaces, si el fitxer d'estat global es corromp, podries perdre l'accés a tots els entorns.
3. **Versatilitat de Configuració:** És més fàcil gestionar diferències estructurals (com per exemple que `staging` tingui un VPC Peering, però `prod` no) quan cada entorn té el seu propi codi `main.tf`. Amb workspaces això requeriria molt d'ús de condicionals (`count` i expressions ternàries), generant codi difícil de mantenir.

## Instruccions Pas a Pas: Com Propagar Canvis (Dev -> Staging)

La propagació de canvis entre entorns ha de seguir un cert flux de treball per garantir la seguretat:

1. **Desenvolupament en Dev:**
   - Navega a `environments/dev`.
   - Fes canvis als valors del fitxer `dev.terraform.tfvars` o a l'estructura del `main.tf`.
   - Executa `terraform plan` per revisar què es canviarà.
   - Si tot és correcte, aplica els canvis amb `terraform apply`.
   - Valida manualment que els recursos funcionen.

2. **Propagació a Staging:**
   - Si els canvis eren estructurals, copia o replica les modificacions al `main.tf` de `environments/staging`.
   - Navega a `environments/staging`.
   - Executa `terraform init` (si s'ha afegit algun mòdul).
   - Executa `terraform plan` per observar l'impacte d'aquests canvis en l'entorn de staging.
   - Aplica els canvis amb `terraform apply`.
   - Valida que els sistemes (i el VPC Peering) continuen funcionant.

3. *(Opcional)* **Pas a Producció:**
   - Repetir els passos de staging a `environments/prod`, evitant qualsevol recurs exclusiu d'entorns de prova.

## Aïllament de l'Estat i Gestió de Riscos

### Aïllament de State
L'estat o *State File* és el document on Terraform desa la relació entre els recursos creats al món real (AWS) i el teu codi. 
En la nostra arquitectura:
- Utilitzem el backend **S3** amb directoris separats. A l'estar en diferents *keys* (`dev/terraform.tfstate`, `staging/...`), els estats són totalment independents. Un error manipulant els objectes de `dev` no pot afectar `prod`.
- **State Locking:** A partir de Terraform 1.7, S3 suporta bloqueig natiu de l'estat activant `use_lockfile = true`. Abans, requeríem una taula DynamoDB per indicar a altres usuaris que s'estava executant Terraform. Amb aquest nou mecanisme integrat, si dos membres de l'equip intenten fer un `terraform apply` al mateix entorn alhora, Terraform posarà en cua una execució i bloquejarà l'altra previnent que el fitxer d'estat es corrompi per escriptura múltiple.

### Riscos Inadmissibles i Prevenció
- **Riscos de Recursos Compartits:** A l'utilitzar VPC Peering entre `dev` i `staging`, hi ha un risc que una configuració dolenta en els Security Groups de Staging obri la porta a trànsit inesperat des de Dev o viceversa. Cal mantenir rutes estrictes.
- **Costos en AWS Academy:** Si es deixen infraestructures enceses o configurades per instàncies excessives (com múltiples NAT Gateways, els quals s'han omès en comptes d'utilitzar instàncies en subxarxes públiques o IPs elàstiques directes on sigui tolerable pel laboratori), es poden acabar els crèdits del Lab ràpidament. L'ús de `multi_az = false` per RDS i models d'emmagatzematge limitat ajuden a mitigar aquest risc.
