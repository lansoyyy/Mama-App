# Edit Profile & Forgot Password Features

## ✅ New Features Added

### 1. Edit Profile Screen
**Location:** `lib/screens/profile/edit_profile_screen.dart`

#### Features:

**Profile Picture Management:**
- Circular avatar with edit button overlay
- Options to:
  - Take photo with camera
  - Choose from gallery
  - Remove current photo
- Visual feedback with dialogs

**Personal Information Section:**
- ✅ Full Name (validated, required)
- ✅ Email Address (validated with @ check, required)
- ✅ Phone Number (validated, required)
- ✅ Date of Birth (date picker)
- ✅ Blood Type (dropdown: A+, A-, B+, B-, AB+, AB-, O+, O-)
- ✅ User Type (dropdown: Mother, Caregiver, Health Worker)
- ✅ Address (multi-line text field)

**Emergency Contact Section:**
- Emergency contact name and phone number
- Format: "Name - Phone Number"
- Validated and required

**Medical Information Section:**
- Display current medical info:
  - Allergies
  - Chronic Conditions
  - Current Medications count
- "Update Medical Information" button opens dialog to edit:
  - Allergies (multi-line)
  - Chronic Conditions (multi-line)

**Security:**
- "Change Password" button
- Dialog with:
  - Current password field
  - New password field
  - Confirm new password field
  - Password match validation

**Actions:**
- Save Changes button (validates all fields)
- Success feedback with snackbar
- Auto-navigates back to profile on save

---

### 2. Forgot Password Screen
**Location:** `lib/screens/auth/forgot_password_screen.dart`

#### Features:

**Initial View:**
- Lock reset icon with circular background
- Clear title: "Forgot Password?"
- Descriptive subtitle explaining the process
- Email input field with validation
- "Send Reset Link" button with loading state
- "Back to Login" link

**Success View (After Email Sent):**
- Success icon (check mark with email)
- "Check Your Email" title
- Shows the email address where link was sent
- **Step-by-step instructions card:**
  1. Check your email inbox
  2. Click the reset link in the email
  3. Create a new password
  4. Login with your new password
- "Resend Email" button
- "Back to Login" button
- "Didn't receive the email?" help link

**Help Dialog:**
- Troubleshooting tips:
  - Check spam/junk folder
  - Verify email address is correct
  - Wait a few minutes and try again
  - Contact support if issue persists
- Support email displayed
- "Contact Support" button

**Validation:**
- Email format validation
- Required field validation
- Loading state during submission

---

## Updated Files

### 1. Login Screen (`lib/screens/auth/login_screen.dart`)
**Changes:**
- ✅ Forgot Password link now navigates to `/forgot-password`
- Previously was a TODO comment

### 2. Profile Screen (`lib/screens/profile/profile_screen.dart`)
**Changes:**
- ✅ Edit Profile button now navigates to `/edit-profile`
- Previously showed "coming soon" snackbar
- Removed unused settings items (Notifications, Theme, Privacy, Help)

### 3. Main App Routes (`lib/main.dart`)
**Added Routes:**
```dart
'/edit-profile': (context) => const EditProfileScreen(),
'/forgot-password': (context) => const ForgotPasswordScreen(),
```

**Added Imports:**
```dart
import 'screens/profile/edit_profile_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
```

### 4. Constants (`lib/utils/constants.dart`)
**Added:**
```dart
static const double paddingXXL = 48.0;
```
- Needed for larger spacing in forgot password screen

---

## Navigation Flow

### Edit Profile Flow:
```
Profile Tab → Edit Profile Button → Edit Profile Screen
                                   ↓
                            [Make Changes]
                                   ↓
                            Save Changes Button
                                   ↓
                          Success Snackbar → Back to Profile
```

### Forgot Password Flow:
```
Login Screen → Forgot Password Link → Forgot Password Screen
                                     ↓
                              [Enter Email]
                                     ↓
                            Send Reset Link Button
                                     ↓
                              Success View
                                     ↓
                    [Check Email & Follow Instructions]
                                     ↓
                            Back to Login Button → Login Screen
```

---

## UI/UX Features

### Edit Profile Screen:
- ✅ Form validation with error messages
- ✅ Date picker for birth date
- ✅ Dropdown selectors for blood type and user type
- ✅ Multi-line text fields for address
- ✅ Sectioned layout for better organization
- ✅ Medical info display cards
- ✅ Interactive dialogs for:
  - Profile picture selection
  - Medical information update
  - Password change
- ✅ Success/error feedback with snackbars
- ✅ Consistent app theme and colors

### Forgot Password Screen:
- ✅ Two-state UI (form view & success view)
- ✅ Loading state during submission
- ✅ Clear visual feedback with icons
- ✅ Step-by-step instructions
- ✅ Help dialog for troubleshooting
- ✅ Resend email functionality
- ✅ Email validation
- ✅ Consistent branding with app colors

---

## Form Validations

### Edit Profile:
- **Name:** Required, cannot be empty
- **Email:** Required, must contain @
- **Phone:** Required, cannot be empty
- **Emergency Contact:** Required, cannot be empty
- **Password Change:** New password must match confirmation

### Forgot Password:
- **Email:** Required, must contain @

---

## User Feedback

### Success Messages:
- ✅ Profile updated successfully
- ✅ Medical information updated
- ✅ Password changed successfully
- ✅ Reset link sent to email
- ✅ Photo removed

### Error Messages:
- ❌ Please enter your name
- ❌ Please enter a valid email
- ❌ Please enter your phone number
- ❌ Please enter emergency contact
- ❌ Passwords do not match
- ❌ Please fill in all fields

### Info Messages:
- ℹ️ Camera feature coming soon
- ℹ️ Gallery feature coming soon
- ℹ️ Contact support feature coming soon

---

## Dialogs & Modals

### Edit Profile Screen:
1. **Profile Picture Dialog:**
   - Take Photo
   - Choose from Gallery
   - Remove Photo

2. **Medical Information Dialog:**
   - Allergies text field
   - Chronic Conditions text field
   - Save/Cancel buttons

3. **Change Password Dialog:**
   - Current Password field
   - New Password field
   - Confirm Password field
   - Change/Cancel buttons

### Forgot Password Screen:
1. **Help Dialog:**
   - Troubleshooting tips
   - Support email
   - Contact Support button

---

## Backend Integration Points

### Edit Profile:
```dart
void _saveProfile() {
  // TODO: Implement API call to save profile
  // POST /api/user/profile
  // Body: {
  //   name, email, phone, dateOfBirth,
  //   bloodType, userType, address,
  //   emergencyContact
  // }
}
```

### Medical Information:
```dart
// TODO: POST /api/user/medical-info
// Body: { allergies, chronicConditions }
```

### Change Password:
```dart
// TODO: POST /api/user/change-password
// Body: { currentPassword, newPassword }
```

### Forgot Password:
```dart
void _sendResetLink() {
  // TODO: Implement password reset API call
  // POST /api/auth/forgot-password
  // Body: { email }
}
```

### Profile Picture Upload:
```dart
// TODO: POST /api/user/profile-picture
// Body: FormData with image file
```

---

## Testing Checklist

### Edit Profile Screen:
- [ ] Navigate from profile screen
- [ ] View all pre-filled data
- [ ] Edit each field
- [ ] Test date picker
- [ ] Test dropdown selectors
- [ ] Click profile picture edit button
- [ ] View profile picture options dialog
- [ ] Click "Update Medical Information"
- [ ] Edit medical info in dialog
- [ ] Click "Change Password"
- [ ] Test password change dialog
- [ ] Test form validation (empty fields)
- [ ] Test email validation
- [ ] Save changes successfully
- [ ] Verify snackbar appears
- [ ] Verify navigation back to profile

### Forgot Password Screen:
- [ ] Navigate from login screen
- [ ] View initial form
- [ ] Test email validation
- [ ] Submit with valid email
- [ ] View loading state
- [ ] View success screen
- [ ] Read step-by-step instructions
- [ ] Click "Resend Email"
- [ ] Click "Back to Login"
- [ ] Click "Didn't receive email?"
- [ ] View help dialog
- [ ] Close help dialog
- [ ] Navigate back to login

---

## File Structure

```
lib/
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart (Updated - forgot password link)
│   │   └── forgot_password_screen.dart (NEW)
│   └── profile/
│       ├── profile_screen.dart (Updated - edit profile navigation)
│       └── edit_profile_screen.dart (NEW)
├── utils/
│   └── constants.dart (Updated - added paddingXXL)
└── main.dart (Updated - added routes)
```

---

## Design Highlights

### Color Usage:
- **Primary Pink:** Main actions, icons
- **Success Green:** Success states, confirmations
- **Info Blue:** Help information, instructions
- **Error Red:** Validation errors, destructive actions
- **Light backgrounds:** Cards, input fields

### Typography:
- **Urbanist Bold:** Headings, titles
- **Urbanist Medium:** Labels, buttons
- **Urbanist Regular:** Body text, descriptions

### Spacing:
- Consistent padding throughout
- Proper section separation
- Comfortable tap targets
- Breathing room for content

---

## Next Steps

1. **Backend Integration:**
   - Implement API endpoints
   - Add authentication tokens
   - Handle API errors
   - Add loading states

2. **Image Upload:**
   - Integrate image picker
   - Add image compression
   - Implement upload progress
   - Handle upload errors

3. **Email Service:**
   - Configure email service
   - Design password reset email template
   - Add email verification
   - Handle email delivery failures

4. **State Management:**
   - Add Provider/Riverpod
   - Persist user data
   - Sync across app
   - Handle offline mode

5. **Security:**
   - Add password strength indicator
   - Implement secure token storage
   - Add biometric authentication option
   - Implement session management
