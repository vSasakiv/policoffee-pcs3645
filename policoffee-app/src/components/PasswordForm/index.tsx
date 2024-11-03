import { IonItem, IonButton, IonInput, IonIcon } from "@ionic/react";
import { ErrorMessage } from "@hookform/error-message";
import { useForm, SubmitHandler, FieldValues } from "react-hook-form";
import styles from "./PasswordForm.module.css";

interface PasswordFormProps {
  onSubmit: SubmitHandler<FieldValues>;
  submitBtnText: string;
  btnIcon: string;
  placeholder: string;
}

const PasswordForm: React.FC<PasswordFormProps> = ({
  onSubmit,
  submitBtnText,
  btnIcon,
  placeholder,
}) => {
  const {
    handleSubmit,
    register,
    formState: { errors },
  } = useForm();

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div className={styles.input}>
        <IonInput
          color={errors.senha ? "danger" : ""}
          type="password"
          {...register("senha", {
            required: "Insira uma senha de 10 caracteres!",
            pattern: {
              value: /^[\x20-\x7E]{10}$/,
              message: "A senha deve ter exatamente 10 caracteres ASCII",
            },
          })}
          placeholder={placeholder}
          aria-label="senha"
        />
      </div>
      <ErrorMessage
        errors={errors}
        name="senha"
        as={<div style={{ color: "red" }} />}
      />
      <div>
        <IonButton
          onClick={() => console.log("Erros:", errors)}
          className="ion-margin-top"
          type="submit"
          expand="full"
        >
          <IonIcon slot="start" icon={btnIcon}></IonIcon>
          {submitBtnText}
        </IonButton>
      </div>
    </form>
  );
};

export default PasswordForm;
