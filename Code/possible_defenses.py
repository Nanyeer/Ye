import torch
import numpy as np
import random


# Privacy Preserving Deep Learning
def bound(grad, gamma):
    if grad < -gamma:
        return -gamma
    elif grad > gamma:
        return gamma
    else:
        return grad


def generate_lap_noise(beta):
    # beta = sensitivity / epsilon
    u1 = np.random.random()
    u2 = np.random.random()
    if u1 <= 0.5:
        n_value = -beta * np.log(1. - u2)
    else:
        n_value = beta * np.log(u2)
    # print(n_value)
    return n_value


def sigma(x, c, sensitivity):
    x = 2. * c * sensitivity / x
    return x


def get_grad_num(layer_grad_list):
    num_grad = 0
    num_grad_per_layer = []
    for grad_tensor in layer_grad_list:
        num_grad_this_layer = 0
        if len(grad_tensor.shape) == 1:
            num_grad_this_layer = grad_tensor.shape[0]
        elif len(grad_tensor.shape) == 2:
            num_grad_this_layer = grad_tensor.shape[0] * grad_tensor.shape[1]
        num_grad += num_grad_this_layer
        num_grad_per_layer.append(num_grad_this_layer)
    return num_grad, num_grad_per_layer


def get_grad_layer_id_by_grad_id(num_grad_per_layer, id):
    id_layer = 0
    id_temp = id
    for num_grad_this_layer in num_grad_per_layer:
        id_temp -= num_grad_this_layer
        if id_temp >= 0:
            id_layer += 1
        else:
            id_temp += num_grad_this_layer
            break
    return id_layer, id_temp


def get_one_grad_by_grad_id(layer_grad_list, num_grad_per_layer, id):
    id_layer, id_in_this_layer = get_grad_layer_id_by_grad_id(num_grad_per_layer, id)
    grad_this_layer = layer_grad_list[id_layer]
    if len(grad_this_layer.shape) == 1:
        the_grad = grad_this_layer[id_in_this_layer]
    else:
        the_grad = grad_this_layer[id_in_this_layer // grad_this_layer.shape[1]][
            id_in_this_layer % grad_this_layer.shape[1]]
    return the_grad


def set_one_grad_by_grad_id(layer_grad_list, num_grad_per_layer, id, set_value):
    id_layer, id_in_this_layer = get_grad_layer_id_by_grad_id(num_grad_per_layer, id)
    grad_this_layer = layer_grad_list[id_layer]
    if len(grad_this_layer.shape) == 1:
        layer_grad_list[id_layer][id_in_this_layer] = set_value
    else:
        layer_grad_list[id_layer][id_in_this_layer // grad_this_layer.shape[1]][
            id_in_this_layer % grad_this_layer.shape[1]] = set_value


def dp_gc_ppdl(epsilon, sensitivity, layer_grad_list, theta_u, gamma, tau):
    grad_num, num_grad_per_layer = get_grad_num(layer_grad_list)
    c = int(theta_u * grad_num)
    # print("c:", c)
    # exit()
    epsilon1 = 8. / 9 * epsilon
    epsilon2 = 2. / 9 * epsilon
    used_grad_ids = []
    really_useful_grad_ids = []
    done_grad_count = 0
    while 1:
        r_tau = generate_lap_noise(sigma(epsilon1, c, sensitivity))
        while 1:
            while 1:
                grad_id = random.randint(0, grad_num - 1)
                if grad_id not in used_grad_ids:
                    used_grad_ids.append(grad_id)
                    break
                if len(used_grad_ids) == grad_num:
                    return
            grad = get_one_grad_by_grad_id(layer_grad_list, num_grad_per_layer, grad_id)
            r_w = generate_lap_noise(2 * sigma(epsilon1, c, sensitivity))
            if abs(bound(grad, gamma)) + r_w >= tau + r_tau:
                r_w_ = generate_lap_noise(sigma(epsilon2, c, sensitivity))
                set_one_grad_by_grad_id(layer_grad_list, num_grad_per_layer, grad_id, bound((grad + r_w_), gamma))
                really_useful_grad_ids.append(grad_id)
                done_grad_count += 1
                if done_grad_count >= c:
                    for id in range(0, grad_num):
                        if id not in really_useful_grad_ids:
                            set_one_grad_by_grad_id(layer_grad_list, num_grad_per_layer, id, 0.)
                    # print("really_useful_grad_ids:", really_useful_grad_ids)
                    # print("len really_useful_grad_ids:", len(really_useful_grad_ids))
                    # exit()
                    return
                else:
                    break


# Multistep gradient
def multistep_gradient(tensor, bound_abs, bins_num=12):
    # Criteo 1e-3
    max_min = 2 * bound_abs
    interval = max_min / bins_num
    tensor_ratio_interval = torch.div(tensor, interval)
    tensor_ratio_interval_rounded = torch.round(tensor_ratio_interval)
    tensor_multistep = tensor_ratio_interval_rounded * interval
    return tensor_multistep


# Gradient Compression
class TensorPruner:
    def __init__(self, zip_percent):
        self.thresh_hold = 0.
        self.zip_percent = zip_percent

    def update_thresh_hold(self, tensor):
        tensor_copy = tensor.clone().detach()
        tensor_copy = torch.abs(tensor_copy)
        survivial_values = torch.topk(tensor_copy.reshape(1, -1),
                                      int(tensor_copy.reshape(1, -1).shape[1] * self.zip_percent))
        self.thresh_hold = survivial_values[0][0][-1]

    def prune_tensor(self, tensor):
        # whether the tensor to process is on cuda devices
        background_tensor = torch.zeros(tensor.shape).to(torch.float)
        if 'cuda' in str(tensor.device):
            background_tensor = background_tensor.cuda()
        # print("background_tensor", background_tensor)
        tensor = torch.where(abs(tensor) > self.thresh_hold, tensor, background_tensor)
        # print("tensor:", tensor)
        return tensor


# Differential Privacy(Noisy Gradients)
class DPLaplacianNoiseApplyer():
    def __init__(self, beta):
        self.beta = beta

    def noisy_count(self):
        # beta = sensitivity / epsilon
        beta = self.beta
        u1 = np.random.random()
        u2 = np.random.random()
        if u1 <= 0.5:
            n_value = -beta * np.log(1. - u2)
        else:
            n_value = beta * np.log(u2)
        n_value = torch.tensor(n_value)
        # print(n_value)
        return n_value

    def laplace_mech(self, tensor):
        # generate noisy mask
        # whether the tensor to process is on cuda devices
        noisy_mask = torch.zeros(tensor.shape).to(torch.float)
        if 'cuda' in str(tensor.device):
            noisy_mask = noisy_mask.cuda()
        noisy_mask = noisy_mask.flatten()
        for i in range(noisy_mask.shape[0]):
            noisy_mask[i] = self.noisy_count()
        noisy_mask = noisy_mask.reshape(tensor.shape)
        # print("noisy_tensor:", noisy_mask)
        tensor = tensor + noisy_mask
        return tensor

class KSSController:
    """
    Key‑Controlled Secret Subsampling.
    在主动方本地，对一个 batch 的样本梯度 g_i 生成子采样掩码，
    只平均子集样本的梯度并做无偏重加权。
    """

    def __init__(self, pmin: float, pmax: float, seed: int):
        self.pmin = pmin
        self.pmax = pmax
        self.rng = random.Random(seed)

    def subsample_and_reweight(self, per_sample_grads, epoch: int, batch_id: int):
        """
        per_sample_grads: Tensor, shape (B, D) 或 (B, C, H, W) 先展平再用
        返回: g_kss, shape 与单个梯度相同，为无偏平均梯度。
        """
        B = per_sample_grads.shape[0]
        device = per_sample_grads.device

        # 用 seed || epoch || batch_id 生成“密钥控制”的子密钥
        # 这里直接用 Python PRNG + epoch/batch 拼接，真实实现可换成 PRF
        self.rng.seed((epoch + 1) * 1000003 + (batch_id + 1))

        # 为每个样本生成随机采样概率 p_i ∈ [pmin, pmax]
        r = torch.empty(B, device=device).uniform_(0.0, 1.0)
        p = self.pmin + (self.pmax - self.pmin) * r

        # Bernoulli 子采样
        m = torch.bernoulli(p).to(device)  # 0/1, shape (B,)
        mask = m > 0

        # 如果极端情况下全 0，退化为全量平均，避免数值问题
        if mask.sum() == 0:
            return per_sample_grads.mean(dim=0, keepdim=False)

        # 对被选中的样本做无偏重加权: g_kss = 1/B * Σ (m_i/p_i * g_i)
        weight = (m / p).view(B, *([1] * (per_sample_grads.dim() - 1)))
        weighted = weight * per_sample_grads
        g_kss = weighted.sum(dim=0) / float(B)

        return g_kss


class KFMController:
    """
    Key‑Controlled Feature‑Level Masking.
    在平均梯度上叠加零均值掩码，破坏“特征‑梯度”的稳定关联。
    """

    def __init__(self, beta: float, seed: int):
        self.beta = beta
        self.rng = random.Random(seed)

    def mask(self, g_mean, feat_mean_enc, epoch: int, batch_id: int):
        """
        g_mean: Tensor, shape (D,) 或 (C,H,W) 展平后再 reshape.
        feat_mean_enc: 被动方提供的“加密批次特征均值”的张量，
                       这里只当成与特征维度相同的向量参与 PRNG 派生。
        返回: g_kfm, 与 g_mean 同形状。
        """
        device = g_mean.device
        flat_g = g_mean.view(-1)
        flat_feat_mean = feat_mean_enc.view(-1)

        # PRNG 种子由密钥 + epoch + batch_id + 特征统计派生
        # 这里简化为 hash 风格，真实实现可替换为密码学 PRF
        seed_val = (epoch + 1) * 1000003 + (batch_id + 1)
        # 再用特征均值的符号做一点扰动，保证与特征统计相关
        sign_hash = int(torch.sign(flat_feat_mean).sum().item())
        self.rng.seed(seed_val + sign_hash)

        # 生成零均值掩码 u, ||u|| 与 ||g_mean|| 同数量级，强度由 β 控制
        dim = flat_g.numel()
        noise = torch.empty(dim, device=device).normal_(mean=0.0, std=1.0)

        # 投影到 g_mean 方向/正交方向的组合: u = β·proj + (1-β)·orth
        g_norm = flat_g.norm() + 1e-8
        proj_coef = (noise.dot(flat_g) / (g_norm ** 2))
        proj = proj_coef * flat_g
        orth = noise - proj
        u = self.beta * proj + (1.0 - self.beta) * orth

        # 零均值约束
        u = u - u.mean()

        # 调整尺度，避免严重破坏任务精度
        scale = (flat_g.norm() / (u.norm() + 1e-8))
        u = 0.1 * scale * u  # 0.1 可视为一个默认 mask 强度，可调

        flat_g_kfm = flat_g + u
        g_kfm = flat_g_kfm.view_as(g_mean)
        return g_kfm