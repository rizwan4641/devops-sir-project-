import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || "http://localhost:8080/api/v1";

// Configure axios with security headers
const apiClient = axios.create({
    baseURL: API_BASE_URL,
    timeout: 10000,
    headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
    },
    withCredentials: true
});

// Add request interceptor for CSRF protection
apiClient.interceptors.request.use(
    (config) => {
        const token = document.querySelector('meta[name="_csrf"]')?.getAttribute('content');
        if (token) {
            config.headers['X-CSRF-TOKEN'] = token;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

class EmployeeService {

    getEmployees(){
        return apiClient.get('/employees');
    }

    createEmployee(employee){
        return apiClient.post('/employees', employee);
    }

    getEmployeeById(employeeId){
        return apiClient.get(`/employees/${employeeId}`);
    }

    updateEmployee(employee, employeeId){
        return apiClient.put(`/employees/${employeeId}`, employee);
    }

    deleteEmployee(employeeId){
        return apiClient.delete(`/employees/${employeeId}`);
    }
}

export default new EmployeeService()